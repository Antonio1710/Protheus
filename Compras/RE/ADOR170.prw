#INCLUDE "MATR170.CH"
#INCLUDE "PROTHEUS.CH"
#include "AP5MAIL.CH"

/*/{Protheus.doc} User Function ADOR170
	Emissao do Boletim de Entrada
	@author HCCONSYS
	@since 13/04/2009
	@version 01
	@history Chamado 047935 - Fernando Sigoli - 25/03/2019 - Quando chamado pela Rotina da central, imprimir a NF posicionionado
	@history Chamado 047935 - Adriana         - 24/05/2019 - Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM
	@history Chamado 053259 - William Costa   - 23/01/2020 - Identificado que o boletim de entrada via email só é gerado, se os usuarios gerarem a impressão do boletim de Entrada, foi retirado a user function que envia email e enviado para o ponto de entrada da nota fiscal de entrada MT103FIM
/*/

User Function ADOR170(cAlias,nReg,nOpcx)

	Local wnrel  		:= "ADOR170"
	Local cDesc1 		:= STR0001		// "Este programa ira emitir o Boletim de Entrada."
	Local cDesc2 		:= ""
	Local cDesc3 		:= ""
	Local cString		:= "SF1"
	Local aArea			:= GetArea()
	Local aAreaSF1		:= SF1->(GetArea())
	Local nReg        := NIL 

	Local _cRet := ""

	if alltrim(FUNNAME()) $ "MATA103" .or. IsInCallStack("U_CENTNFEXM")  //Chamado: 047935 - Fernando Sigoli 25/03/2019.
	nReg := Recno()
	endif   

	STATIC aTamSXG

	Private lAuto		:= (nReg!=Nil)
	Private Titulo		:= STR0002		// "Boletim de Entrada"
	Private aReturn	:= {STR0003, 1,STR0004, 1, 2, 1, "",1 }		// "Zebrado"###"Administracao"
	Private nomeprog	:= "ADOR170"
	Private nLastKey	:= 0
	Private cPerg		:= If(lAuto,"","MTR170")
	Private cAuxLinha	:= SPACE(132)

	aTamSXG := If(aTamSXG == NIL, TamSXG("001"), aTamSXG)

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	AjustaSx1()
	Pergunte("MTR170",.F.)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utiLizadas para parametros                         ³
	//³ mv_par01             // da Data                              ³
	//³ mv_par02             // ate a Data                           ³
	//³ mv_par03             // Nota De                              ³
	//³ mv_par04             // Nota Ate                             ³
	//³ mv_par05             // Imprime Centro Custo X Cta. Contabil ³
	//³ mv_par06             // Imprimir o Custo ? Total ou Unit rio ³
	//³ mv_par07             // Ordenar itens por? Item+Prod/ Prd+It ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"",,"M",,!lAuto)

	If nLastKey == 27
		dbClearFilter()
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		dbClearFilter()
		Return
	Endif

	RptStatus({|lEnd| R170Imp(@lEnd,wnrel,cString,nReg)},Titulo)


	RestArea(aAreaSF1)
	RestArea(aArea)

Return

/*/{Protheus.doc} Static Function R170Imp
	Chamada e impressao do Relatorio
	@author HCCONSYS
	@since 13/04/2009
	@version 01
/*/

Static Function R170Imp(lEnd,wnrel,cString,nReg)

	Local li          := 99
	Local cLocDest    := GetMV("MV_CQ")
	Local aDivergencia:= {}
	Local aPedidos  	:= {}
	Local aDescPed    := {}
	Local aCQ         := {}
	Local aEntCont    := {}
	Local _lQtdErr    := .F.
	Local _lPrcErr    := .F.
	Local _QtdSal     := .F.
	Local _lTes       := .F.
	Local cForAnt     := 0
	Local nDocAnt     := 0
	Local nCt         := 0
	Local nX          := 0
	Local nImp        := 0
	Local nRecno      := 0
	Local lPedCom     := .F.
	Local cQuery      := ""
	Local cArqInd     := ""
	Local cArqIndSD1  := ""
	Local cParcIR     := ""
	Local cParcINSS   := ""
	Local cParcISS    := ""
	Local cParcCof    := ""
	Local cParcPis    := ""
	Local cParcCsll   := ""
	Local cParcSest   := ""
	Local cPrefixo
	Local aImps       := {}
	Local nBasePis    := 0
	Local nValPis     := 0
	Local nBaseCof    := 0
	Local nValCof     := 0
	Local aRelImp     := MaFisRelImp("MT100",{ "SF1" })
	Local lFornIss    := (SE2->(FieldPos("E2_FORNISS")) > 0 .And. SE2->(FieldPos("E2_LOJAISS")) > 0)
	Local cFornIss 	  := ""
	Local cLojaIss    := ""
	Local cRemito     := ""
	Local cItemRem    := ""
	Local cSerieRem   := ""
	Local cFornRem    := ""
	Local cLojaRem    := ""
	Local cCodRem     := ""
	Local cPedido     := ""
	Local cItemPed    := ""

	Private cAliasSF1	:= "SF1"

	If lAuto
		dbSelectArea("SF1")
		dbGoto(nReg)
		MV_PAR03 := SF1->F1_DOC
		MV_PAR04 := SF1->F1_DOC
		MV_PAR01 := SF1->F1_DTDIGIT
		MV_PAR02 := SF1->F1_DTDIGIT
	Else
		dbSelectArea("SF1")
		dbSetOrder(1)

		cQuery := "SELECT *  "
		cQuery += "FROM "	    + RetSqlName( 'SF1' )
		cQuery += " WHERE "
		cQuery += "F1_FILIAL='"    	+ xFilial( 'SF1' )	+ "' AND "
		cQuery += "F1_DTDIGIT>='"  	+ DTOS(MV_PAR01)	+ "' AND "
		cQuery += "F1_DTDIGIT<='"  	+ DTOS(MV_PAR02)	+ "' AND "
		cQuery += "F1_DOC>='"  		+ MV_PAR03			+ "' AND "
		cQuery += "F1_DOC<='"  		+ MV_PAR04			+ "' AND "
		cQuery += "NOT ("+IsRemito(3,'F1_TIPODOC')+ ") AND "
		cQuery += "D_E_L_E_T_<>'*' "
		cQuery += "ORDER BY " + SqlOrder(SF1->(IndexKey()))
		cQuery := ChangeQuery(cQuery)

		cAliasSF1 := "QRYSF1"
		dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), 'QRYSF1', .F., .T.)
		aEval(SF1->(dbStruct()),{|x| If(x[2]!="C",TcSetField("QRYSF1",AllTrim(x[1]),x[2],x[3],x[4]),Nil)})

		If ( mv_par07 == 1 )
			cArqIndSD1 := CriaTrab(,.F.)
			IndRegua( "SD1", cArqIndSD1, "D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM" )
		EndIf

	EndIf

	If !lAuto
		(cAliasSF1)->(dbGoTop())
	EndIf

	SF1->(SetRegua(LastRec()))
	While ( (cAliasSF1)->(!Eof()) .And. (cAliasSF1)->F1_FILIAL == xFilial("SF1") .And.;
			((cAliasSF1)->F1_DOC <= MV_PAR04) )

		IncRegua()
		aCQ	:= {}
		If lEnd
			@PROW()+1,001 PSAY STR0005
			Exit
		Endif

		dbSelectArea(cAliasSF1)
		If !Empty(aReturn[7]) .And. !&(aReturn[7])
			(cAliasSF1)->(dbSkip())
			Loop
		EndIf
		If (cAliasSF1)->F1_DTDIGIT < MV_PAR01 .OR. (cAliasSF1)->F1_DTDIGIT > MV_PAR02
			(cAliasSF1)->(dbSkip())
			Loop
		EndIf

		If (cAliasSF1)->F1_DOC < MV_PAR03 .or. (cAliasSF1)->F1_DOC > MV_PAR04
			(cAliasSF1)->(dbSkip())
			Loop
		EndIf

		//If (lAuto .And. (cAliasSF1)->(Recno()) <> nReg)
		//	(cAliasSF1)->(dbSkip())
		//	Loop
		//EndIf
		
		dbSelectArea("SD1")
		dbSeek(xFilial("SD1")+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)

		dbSelectArea(cAliasSF1)
		If li > 20						// Impressao do Cabecalho
			//li := R170Cabec()
			li := R170CabX()
		EndIf

		// Impressao dos itens da Nota de Entrada.

		dbSelectArea("SD1")
		nCt     			:= 1
		nDocAnt 			:= D1_DOC+D1_SERIE
		cForAnt 			:= D1_FORNECE+D1_LOJA
		aDivergencia 	:= {}
		aPedidos     	:= {}
		aDescPed     	:= {}
		aEntCont     	:= {}

		//                                 1         2         3         4         5         6         7         8         9        10        11        12        13
		//                         012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
		//                         999999999999999 XX XXXXXXXXXXXXXXXXXXXX 99999999.99 99,999,999.99 999,999,999.99  99  99 12345678901234567890 999 9999 99,999,999.99
		//                         999999999999999 XX XXXXXXXXXXXXXXXXX XX 99999999.99 99,999,999.99 999,999,999.99  99  99 12345678901234567890 999 9999 99,999,999.99
		If mv_par05 <> 3
			If mv_par08 == 1
				cLinha :=         "               |  |                 |  |           |            |            |     |     |                    |   |     |             "
			Else
				cLinha :=         "               |  |                    |           |            |            |     |     |                    |   |     |             "
			EndIf
		Else
			If mv_par08 == 1
				cLinha :=         "               |  |                 |  |           |            |            |     |     |   |     |             "
			Else
				cLinha :=         "               |  |                    |           |            |            |     |     |   |     |             "	
			EndIf
		EndIf
		@ li,000 PSAY __PrtThinLine()
		li += 1
		@ li,000 PSAY STR0006 // "------------------------------------------------------- DADOS DA NOTA FISCAL -------------------------------------------------------"
		li += 1
		@ li,000 PSAY If(mv_par08==1,If(cPaisLoc<>"BRA",STR0064,STR0063),If(cPaisLoc<>"BRA",STR0044,STR0007))+If(mv_par05==1,"   "+STR0009+"   |",If(mv_par05==2,"   "+STR0010+"   |",""))+STR0011+If(mv_par06==2,STR0012,STR0013)  //"Codigo Material|UN|Descr. da Mercadoria|Quantidade |Vlr. Unitario| Valor Total  |IPI|ICM|   "###"Conta Contabil"###"Centro  Custo "###"   |TES|CFOP|"###"Custo Unit. "###"Custo Total "
		li += 1

		While ( !Eof() .And. SD1->D1_DOC+SD1->D1_SERIE == nDocAnt .And.;
			cForAnt == SD1->D1_FORNECE+SD1->D1_LOJA .And.;
			SD1->D1_FILIAL == xFilial("SD1") )	

			If li >= 60
				li := 1
				@ li,000 PSAY STR0085 //"------------------------------------------------------- ITENS DA NOTA FISCAL -------------------------------------------------------"
				li += 1
				@ li,000 PSAY If(mv_par08==1,If(cPaisLoc<>"BRA",STR0064,STR0063),If(cPaisLoc<>"BRA",STR0044,STR0007))+If(mv_par05==1,"   "+STR0009+"   |",If(mv_par05==2,"   "+STR0010+"   ",""))+STR0011+If(mv_par06==2,STR0012,STR0013)  //"Codigo Material|UN|Descr. da Mercadoria|Quantidade |Vlr. Unitario| Valor Total  |IPI|ICM|   "###"Conta Contabil"###"Centro  Custo "###"   |TES|CFOP|"###"Custo Unit. "###"Custo Total "
				li += 1
				@ li,000 PSAY __PrtThinLine()
				li += 1
			Endif            
			
			// Posiciona Todos os Arquivos Ref. ao Itens

			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+SD1->D1_COD)

			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF4")+SD1->D1_TES)
			
			cPedido   := SD1->D1_PEDIDO
			cItemPed  := SD1->D1_ITEMPC			
			
			If cPaisLoc <> "BRA" .And. !Empty(SD1->D1_REMITO)
				cRemito   := SD1->D1_REMITO
				cItemRem  := SD1->D1_ITEMREM
				cSerieRem := SD1->D1_SERIREM
				cFornRem  := SD1->D1_FORNECE
				cLojaRem  := SD1->D1_LOJA
				cCodRem	  := SD1->D1_COD
			
				aArea := SD1->(GetArea())
			
				dbSelectArea("SD1")
				SD1->(dbSetOrder(1))
				If SD1->(dbSeek(xFilial("SD1")+cRemito+cSerieRem+cFornRem+cLojaRem+cCodRem+Alltrim(cItemRem))) .And. !Empty(SD1->D1_PEDIDO)
					cPedido   := SD1->D1_PEDIDO
					cItemPed  := SD1->D1_ITEMPC			
				Endif
				RestArea(aArea)
			Endif		
			
			dbSelectArea("SC7")
			dbSetOrder(14)
			If dbSeek(xFilial("SC7")+cPedido+cItemPed) .And. !Empty(cPedido) .And. !Empty(cItemPed)
				dbSelectArea("SC1")
				dbSetOrder(1)
				If dbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC)
					lPedCom := .T.
				EndIf

				dbSelectArea("SE4")
				dbSetOrder(1)
				dbSeek(xFilial("SE4")+SC7->C7_COND)

				cProblema := ""
				If ( SD1->D1_QTDPEDI > 0 .And. (SC7->C7_QUANT <> SD1->D1_QTDPEDI) ) .Or. SC7->C7_QUANT <> SD1->D1_QUANT
					cProblema += "Q"
					_lQtdErr := .T.
				Else
					cProblema += " "
				EndIf
				If (SC7->C7_QUANT - SC7->C7_QUJE) < SD1->D1_QUANT  .AND. SD1->D1_TES == "   "
					_QtdSal := .T.
					n_proc1 :=-(SD1->D1_QUANT - (SC7->C7_QUANT - SC7->C7_QUJE)) / SC7->C7_QUANT * 100
				EndIf
				If SD1->D1_TES != "   " .AND. (SC7->C7_QUANT - SC7->C7_QUJE) < 0
					_QtdSal := .T.
					N_PORC1 :=-(SC7->C7_QUANT - SC7->C7_QUJE) / SC7->C7_QUANT * 100
				EndIf
				If IIf(Empty(SC7->C7_REAJUSTE),SC7->C7_PRECO,Formula(SC7->C7_REAJUSTE)) # SD1->D1_VUNIT
					If SC7->C7_MOEDA <> 1
						cProblema := cProblema+"M"
					Else
						cProblema := cProblema+"P"
					EndIf
					_lPrcErr := .T.
				Else
					cProblema := cProblema+" "
				EndIf
				If SC7->C7_DATPRF <> SD1->D1_DTDIGIT
					cProblema := cProblema+"E"
				Else
					cProblema := cProblema+" "
				EndIf
				If !Empty(cProblema)
					aADD(aDivergencia,cProblema)
				Else
					aADD(aDivergencia,"Ok ")
				Endif
				aADD(aPedidos,{SC7->C7_NUM+"/"+SC7->C7_ITEM,;
					SC7->C7_DESCRI,;
					TransForm(SC7->C7_QUANT,PesqPict("SC7","C7_QUANT",11)),;
					TransForm(SC7->C7_PRECO,PesqPict("SC7","C7_PRECO",13)),;
					DTOC(SC7->C7_EMISSAO),;
					DTOC(SC7->C7_DATPRF),;
					SC7->C7_NUMSC+"/"+SC7->C7_ITEMSC,;
					If(lPedCom,SubStr(SC1->C1_SOLICIT,1,15),""),;
					If(lPedCom,SC1->C1_CC,""),;
					AllTrim(SE4->E4_DESCRI)} )
			Else
				aADD(aDivergencia,"Err") 										// "Err"
				aADD(aPedidos,{"","Sem Pedido de Compra","","","","","","","",""}) 		// "Sem Pedido de Compra"
			Endif

			If !Empty(SD1->D1_NUMCQ) .AND. SF4->F4_ESTOQUE == "S"
				AADD(aCQ,SD1->D1_NUMCQ+SD1->D1_COD+cLocDest+"001"+DTOS(SD1->D1_DTDIGIT))
			Endif

			R170LdX(0,cLinha)
			R170LdX(0,SD1->D1_COD)
			R170LdX(16,SD1->D1_UM)
			If mv_par08 == 1
				R170LdX(19,SubStr(SB1->B1_DESC,1,17))
				R170LdX(37,SubStr(SD1->D1_LOCAL,1,2))
			Else
				R170LdX(19,SubStr(SB1->B1_DESC,1,20))
			EndIf
			R170LdX(40,Transform(SD1->D1_QUANT,PesqPict("SD1","D1_QUANT",11)))
			R170LdX(52,TransForm(SD1->D1_VUNIT,PesqPict("SD1","D1_VUNIT",12)))
			If cPaisLoc=="BRA"
				R170LdX(65,Transform(SD1->D1_TOTAL,PesqPict("SD1","D1_TOTAL",12)))
				R170LdX(78,Transform(SD1->D1_IPI,PesqPict("SD1","D1_IPI",5)))
				R170LdX(84,Transform(SD1->D1_PICM,PesqPict("SD1","D1_PICM",5)))
			Else
				R170LdX(73,Transform(SD1->D1_TOTAL,PesqPict("SD1","D1_TOTAL",14)))
			EndIf
			If mv_par05 == 1
				R170LdX(90,SD1->D1_CONTA)
			ElseIf mv_par05 == 2
				R170LdX(90,SD1->D1_CC)
			Endif

			If (( mv_par05 == 1 ) .Or. ( mv_par05 == 2 ))
				R170LdX(111,SD1->D1_TES)
				R170LdX(115,SD1->D1_CF)
				If mv_par06 = 1
					R170LdX(121,Transform(SD1->D1_CUSTO,PesqPict("SD1","D1_CUSTO",10)))
				Else
					R170LdX(121,Transform((SD1->D1_CUSTO/SD1->D1_QUANT),PesqPict("SD1","D1_CUSTO",10)))
				EndIf
			Else
				R170LdX(90,SD1->D1_TES)
				R170LdX(94,SD1->D1_CF)
				If mv_par06 = 1
					R170LdX(100,Transform(SD1->D1_CUSTO,PesqPict("SD1","D1_CUSTO",10)))
				Else
					R170LdX(100,Transform((SD1->D1_CUSTO/SD1->D1_QUANT),PesqPict("SD1","D1_CUSTO",10)))
				EndIf
			EndIf
			R170SayX(Li)

			Li := Li + 1
			If !Empty(SD1->D1_TES)
				_lTES := .T.
			EndIf

			If mv_par08 == 1
				_nCntTam := 18
				While !(AllTrim(SubStr(SB1->B1_DESC,_nCntTam))=="")
					R170LdX(0,cLinha)
					R170LdX(19,SubStr(SB1->B1_DESC,_nCntTam,17))
					_nCntTam := _nCntTam + 17
					R170SayX(Li)
					Li := Li + 1
				EndDo
			Else
				_nCntTam := 21
				While !(AllTrim(SubStr(SB1->B1_DESC,_nCntTam))=="")
					R170LdX(0,cLinha)
					R170LdX(19,SubStr(SB1->B1_DESC,_nCntTam,20))
					_nCntTam := _nCntTam + 20
					R170SayX(Li)
					Li := Li + 1
				EndDo
			EndIf

			If ( mv_par05 == 3 )
				If ( SD1->D1_RATEIO == "1" )
					dbSelectArea("SDE")
					dbSetOrder(1)
					If MsSeek(xFilial("SDE")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM)
						While !Eof() .And. DE_FILIAL+DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF ==;
							xFilial("SDE")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM
							aAdd(aEntCont,{SDE->DE_ITEMNF,SDE->DE_ITEM,SDE->DE_PERC,SDE->DE_CC,SDE->DE_CONTA,SDE->DE_ITEMCTA,SDE->DE_CLVL})
							dbSelectArea("SDE")
							dbSkip()
						EndDo
					EndIf
				Else
					If !Empty(SD1->D1_CC) .Or. !Empty(SD1->D1_CONTA) .Or. !Empty(SD1->D1_ITEMCTA)
						aAdd(aEntCont,{SD1->D1_ITEM," - ","   -   ",SD1->D1_CC,SD1->D1_CONTA,SD1->D1_ITEMCTA,SD1->D1_CLVL})
					EndIf
				EndIf
			EndIf

			dbSelectArea("SD1")
			dbSkip()
		End

		// Imprime Entidades Contabeis
		If Len(aEntCont) > 0
			If Li >= 60
				Li := 1
			Endif
			@ li,000 PSAY __PrtThinLine()
			li += 1
			cLinha :=   "        |      |       |                 |                      |            |              "
			@ Li, 0 PSAY "------------------------------------------------------- ENTIDADES CONTABEIS ---------------------------------------------------------"
			li += 1
			@ Li,000 PSAY "Item NF | Item | % Rat | Centro de Custo | Conta Contabil       | Item Conta | Classe Valor "
			li += 1

			For nX:=1 to Len(aEntCont)
				If Li >= 60
					Li := 1
					cLinha :=   "        |      |       |                 |                      |            |              "
					//@ Li, 0 PSAY STR0061  //"------------------------------------------------------- ENTIDADES CONTABEIS ---------------------------------------------------------"
					@ Li, 0 PSAY "------------------------------------------------------- ENTIDADES CONTABEIS ---------------------------------------------------------"
					li += 1
					//@ Li,000 PSAY STR0062 //"Item NF | Item | % Rat | Centro de Custo | Conta Contabil       | Item Conta | Classe Valor "
					@ Li,000 PSAY "Item NF | Item | % Rat | Centro de Custo | Conta Contabil       | Item Conta | Classe Valor "
					li += 1
				Endif
				R170LdX(0,cLinha)
				R170LdX(0,aEntCont[nX][1])
				R170LdX(10,aEntCont[nX][2])
				R170LdX(16,If(ValType(aEntCont[nX][3])=="N",Transform(aEntCont[nX][3],"@E 999.99"),aEntCont[nX][3]))
				R170LdX(25,aEntCont[nX][4])
				R170LdX(43,aEntCont[nX][5])
				R170LdX(66,aEntCont[nX][6])
				R170LdX(79,aEntCont[nX][7])
				R170SayX(Li)
				li += 1
			Next nX
			aEntCont := {}
		EndIf

		// Imprime produtos enviados ao Controle de Qualidade SD7

		If Len(aCQ) > 0
			If Li >= 60
				Li := 1
			Endif
			li += 1
			//                               1         2         3         4         5         6         7         8         9        10        11        12        13
			//                     012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
			//                     XXXXXXXXXXXXXXX                    XX                               XX                      99/99/9999                        999999
			cLinha :=    "                     |                               |                            |                           |                     "
			@ Li, 0 PSAY STR0015 //"------------------------------------------- PRODUTO(s) ENVIADO(s) AO CONTROLE DE QUALIDADE -----------------------------------------"
			li += 1
			@ Li,000 PSAY STR0016 //"Produto              |         Local Origem          |        Local Destino       |    Data Transferencia     |     Numero do CQ.   "
			li += 1

			For nX:=1 to Len(aCQ)
				If Li >= 60
					Li := 1
					//                               1         2         3         4         5         6         7         8         9        10        11        12        13
					//                     012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
					//                     XXXXXXXXXXXXXXX                    XX                               XX                      99/99/9999                        999999
					cLinha :=    "                     |                               |                            |                           |                     "
					@ Li, 0 PSAY STR0015 //"------------------------------------------- PRODUTO(s) ENVIADO(s) AO CONTROLE DE QUALIDADE -----------------------------------------"
					li += 1
					@ Li,000 PSAY STR0016 //"Produto              |         Local Origem          |        Local Destino       |    Data Transferencia     |     Numero do CQ.   "
					li += 1
				Endif
				dbSelectArea("SD7")
				dbSetOrder(1)
				dbSeek(xFilial("SD7")+aCQ[nX])
				If Found()
					R170LdX(0,cLinha)
					R170LdX(0,SD7->D7_PRODUTO)
					R170LdX(34,SD7->D7_LOCAL)
					R170LdX(68,SD7->D7_LOCDEST)
					R170LdX(92,DTOC(SD7->D7_DATA))
					R170LdX(123,SD7->D7_NUMERO)
					R170SayX(Li)
					li += 1
				Endif
			Next nX
		Endif

		// Imprime Divergencia com Pedido de Compra

		Li := Li + 1
		//                            1         2         3         4         5         6         7         8         9        10        11        12        13
		//                  012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
		//                   123 123456-12 12345678901234567890 99999999,99|99.999.999,99 99/99/9999 99/99/9999 999999/99 xxxxxxxxxxxx 999999999
		If cPaisLoc == "BRA"
			cLinha  :=    "   |         |                    |           |             |          |          |         |               |         |             "
		Else
			cLinha  :=    "   |           |                    |           |             |          |          |            |               |         |             "
		EndIf
		@ li,000 PSAY __PrtThinLine()
		Li += 1
		@ Li,000 PSAY STR0019 //"--------------------------------------------- DIVERGENCIAS COM O PEDIDO DE COMPRA --------------------------------------------------"
		Li += 1
		@ Li,000 PSAY If(cPaisLoc=="BRA",STR0020,STR0058) //"Div|Numero   |Descricao do Produto|Quantidade |Preco Unitar.| Emissao  | Entrega  |   S.C.  |Solicitante    | C.Custo |Cond.Pagto   "
		Li += 1
		If !Empty(aPedidos) .And. !Empty(aDivergencia)
			For nX := 1 To Len(aPedidos)
				If Li > 60
					Li := 0
					@ Li,000 PSAY STR0019 //"--------------------------------------------- DIVERGENCIAS COM O PEDIDO DE COMPRA --------------------------------------------------"
					Li += 1
					@ Li,000 PSAY If(cPaisLoc=="BRA",STR0020,STR0058) //"Div|Numero   |Descricao do Produto|Quantidade |Preco Unitar.| Emissao  | Entrega  |   S.C.  |Solicitante    | C.Custo |Cond.Pagto   "
					Li += 1
				EndIf
				R170LdX(0,cLinha)
				R170LdX(0,aDivergencia[nX])
				R170LdX(4,aPedidos[nX][1])
				If cPaisLoc == "BRA"
					R170LdX(14,AllTrim(Substr(aPedidos[nX][2],1,20)))
					R170LdX(35,aPedidos[nX][3])
					R170LdX(47,aPedidos[nX][4])
					R170LdX(61,aPedidos[nX][5])
					R170LdX(72,aPedidos[nX][6])
					R170LdX(83,aPedidos[nX][7])
					R170LdX(93,aPedidos[nX][8])
					R170LdX(109,aPedidos[nX][9])
					R170LdX(119,aPedidos[nX][10])
				Else
					R170LdX(16,AllTrim(Substr(aPedidos[nX][2],1,18)))
					R170LdX(37,aPedidos[nX][3])
					R170LdX(49,aPedidos[nX][4])
					R170LdX(63,aPedidos[nX][5])
					R170LdX(74,aPedidos[nX][6])
					R170LdX(85,aPedidos[nX][7])
					R170LdX(98,aPedidos[nX][8])
					R170LdX(114,aPedidos[nX][9])
					R170LdX(124,aPedidos[nX][10])
				EndIf
				R170SayX(Li)
				Li += 1
				_nCntTam := 21
				While !(AllTrim(SubStr(aPedidos[nX][2],_nCntTam)) == "")
					R170LdX(0,cLinha)
					R170LdX(14,SubStr(aPedidos[nX][2],_nCntTam,20))
					R170SayX(Li)
					_nCntTam := _nCntTam + 20
					Li += 1
				End
			Next nX
		EndIf

		// Imprime Totais da Nota Fiscal

		If Li >= 60
			Li := 1
		Endif
		dbSelectArea(cAliasSF1)
		@ li,000 PSAY __PrtThinLine()
		Li += 1
		@ Li,000 PSAY STR0023 //"------------------------------------------------------- TOTAIS DA NOTA FISCAL ------------------------------------------------------"
		Li += 1
		//                             1         2         3         4         5         6         7         8         9        10        11        12        13
		//                   012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
		//                      999,999,999,999.99    999,999,999,999.99    999,999,999,999.99    999,999,999,999.99      999,999,999,999.99   999,999,999,999.99
		If cPaisLoc=="BRA"
			cLinha  :=     "                     |                     |                     |                      |                        |                  "
		Else
			cLinha  :=     "                     |                     |                                            |                        |                  "
		EndIf
		@ Li,000 PSAY If(cPaisLoc<>"BRA",STR0046,STR0024) //" BASE DE CALCULO ICMS|  VALOR DO ICMS      |BASE CALC.ICMS SUBST.|  VALOR ICMS SUBST.   |VALOR TOTAL DOS PRODUTOS|    DESCONTOS     "
		Li += 1
		R170LdX(0,cLinha)
		If cPaisLoc=="BRA"
			R170LdX(003,Transform((cAliasSF1)->F1_BASEICM,"@E 999,999,999,999.99"))
			R170LdX(025,Transform((cAliasSF1)->F1_VALICM, "@E 999,999,999,999.99"))
			R170LdX(047,Transform((cAliasSF1)->F1_BRICMS, "@E 999,999,999,999.99"))
			R170LdX(069,Transform((cAliasSF1)->F1_ICMSRET,"@E 999,999,999,999.99"))
		Else
			aImps:=R170IMPT(cAliasSF1)
			R170LdX(003,Transform(aImps[1],"@E 999,999,999,999.99")) // Base de imposto
			R170LdX(025,Transform(aImps[2],"@E 999,999,999,999.99")) // Valor do Imposto
		EndIf
		R170LdX(093,Transform((cAliasSF1)->F1_VALMERC,"@E 999,999,999,999.99"))
		R170LdX(114,Transform((cAliasSF1)->F1_DESCONT,"@E 999,999,999,999.99"))
		R170SayX(Li)
		Li += 1
		@ Li,000 PSAY __PrtThinLine()
		Li += 1
		cLinha  :=    "                        |                         |                        |                         |                             "
		@ Li,000 PSAY If(cPaisLoc<>"BRA",STR0045,STR0025) //"  VALOR DO FRETE        |      VALOR DO SEGURO    | OUTRAS DESPESAS ACESSO.|   VALOR TOTAL DO IPI    |   VALOR TOTAL DA NOTA       "
		Li += 1
		R170LdX(0,cLinha)
		R170LdX(001,Transform((cAliasSF1)->F1_FRETE,  "@E 99,999,999,999,999.99"))
		R170LdX(027,Transform((cAliasSF1)->F1_SEGURO, "@E 99,999,999,999,999.99"))
		R170LdX(053,Transform((cAliasSF1)->F1_DESPESA,"@E 99,999,999,999,999.99"))
		If cPaisLoc=="BRA"
			R170LdX(079,Transform((cAliasSF1)->F1_VALIPI, "@E 99,999,999,999,999.99"))
			R170LdX(108,Transform((cAliasSF1)->F1_VALBRUT,"@E 99,999,999,999,999.99"))
		Else
			R170LdX(079,Transform((cAliasSF1)->F1_VALBRUT,"@E 99,999,999,999,999.99"))
		EndIf
		R170SayX(Li)
		Li += 1
		@ Li,000 PSAY __PrtThinLine()
		Li += 1    
		
		// Imprime desdobramento de Duplicatas.
		aFornece := {{(cAliasSF1)->F1_FORNECE,(cAliasSF1)->F1_LOJA,PadR(MVNOTAFIS,Len(SE2->E2_TIPO))},;
		{PadR(GetMv('MV_UNIAO') ,Len(SE2->E2_FORNECE)),PadR('00',Len(SE2->E2_LOJA)),PadR(MVTAXA,Len(SE2->E2_TIPO)) },;
		{PadR(GetMv('MV_FORINSS'),Len(SE2->E2_FORNECE)),PadR('00',Len(SE2->E2_LOJA)),PadR(MVINSS,Len(SE2->E2_TIPO))},;
		{PadR(GetMv('MV_MUNIC'),Len(SE2->E2_FORNECE)),PadR('00',Len(SE2->E2_LOJA)),PadR(MVISS,Len(SE2->E2_TIPO))} }
		If SE2->(FieldPos("E2_PARCSES")) > 0
			aadd(aFornece,{PadR(GetNewPar('MV_FORSEST',''),Len(SE2->E2_FORNECE)),PadR(IIf(SubStr(GetNewPar('MV_FORSEST',''),Len(SE2->E2_FORNECE)+1)<>"",SubStr(GetNewPar('MV_FORSEST',''),Len(SE2->E2_FORNECE)+1),"00"),Len(SE2->E2_LOJA)),PadR('SES',Len(SE2->E2_TIPO)),"E2_PARCSES",{ || .T. }})
		EndIf


		cPrefixo := If(Empty((cAliasSF1)->F1_PREFIXO),&(GetMV("MV_2DUPREF")),(cAliasSF1)->F1_PREFIXO)
		dbSelectArea("SE2")
		dbSetOrder(6)
		dbSeek(xFilial("SE2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+cPrefixo+(cAliasSF1)->F1_DOC)
		If Found()
			Li += 1
			If Li >= 60
				Li := 1
			Endif
			//                               1         2         3         4         5         6         7         8         9        10        11        12        13
			//                     012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
			//                      123 123456789012A 99/99/9999 99,999,999,999.99                            123 123456789012A 99/99/99   99,999,999,999.99 xxxxxxxxxx
			@ Li,000 PSAY STR0026 //"--------------------------------------------------- DESDOBRAMENTO DE DUPLICATAS ----------------------------------------------------"
			Li += 1
			cLinha :=     "   |             |          |                 |                   ||   |             |          |                 |                 "

			@ Li,000 PSAY STR0027 //"Ser|Titulo/Parc. | Vencto   |Valor do Titulo  | Natureza          ||Ser|Titulo/Parc. | Vencto   |Valor do Titulo  | Natureza        "
			Li += 1

			Col := 0
			R170LdX(0,cLinha)

			dbSelectArea('SE2')
			dbSetOrder(6)
			dbSeek(xFilial('SE2')+aFornece[1][1]+aFornece[1][2]+cPrefixo+(cAliasSF1)->F1_DOC)

			While !Eof() .And. xFilial('SE2')+aFornece[1][1]+aFornece[1][2]+cPrefixo+(cAliasSF1)->F1_DOC==;
				E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM

				If SE2->E2_TIPO == aFornece[1,3]

					R170Dupl(@Li,@Col)
					cParcCSS := SE2->E2_PARCCSS
					cParcIR  := SE2->E2_PARCIR
					cParcINSS:= SE2->E2_PARCINS
					cParcISS := SE2->E2_PARCISS
					cParcCof := SE2->E2_PARCCOF
					cParcPis := SE2->E2_PARCPIS
					cParcCsll:= SE2->E2_PARCSLL
					If lFornIss .And. !Empty(SE2->E2_FORNISS) .And. !Empty(SE2->E2_LOJAISS)
						cFornIss := SE2->E2_FORNISS
						cLojaIss := SE2->E2_LOJAISS
					Else
						cFornIss := aFornece[4,1]
						cLojaIss :=	aFornece[4,2]
					Endif
					cParcSest := IIf(SE2->(FieldPos("E2_PARCSES"))>0,SE2->E2_PARCSES,"")				

					nRecno   := SE2->(Recno())

					dbSelectArea('SE2')
					dbSetOrder(1)
					If (!Empty(cParcIR)).And.dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcIR+aFornece[2,3])
						R170Dupl(@Li,@Col)
					Endif
					If (!Empty(cParcINSS)).And.dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcINSS+aFornece[3,3])
						R170Dupl(@Li,@Col)
					Endif
					If (!Empty(cParcISS)).And.dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcISS+aFornece[4,3]+cFornIss+cLojaIss)
						R170Dupl(@Li,@Col)
					EndIf
					If (!Empty(cParcCof)).And.dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcCof+aFornece[2,3])
						R170Dupl(@Li,@Col)
					Endif
					If (!Empty(cParcPis)).And.dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcPis+aFornece[2,3])
						R170Dupl(@Li,@Col)
					Endif
					If (!Empty(cParcCsll)).And.dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcCsll+aFornece[2,3])
						R170Dupl(@Li,@Col)
					Endif

					If (!Empty(cParcCSS)).And.dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcCSS+aFornece[2,3])
						While !Eof() .And. xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcCSS+aFornece[2,3] ==;
								SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO

							If PadR(GetMv('MV_CSS'),Len(SE2->E2_NATUREZ)) == SE2->E2_NATUREZ
								R170Dupl(@Li,@Col)
							EndIf

							dbSelectArea('SE2')
							dbSetOrder(1)
							dbSkip()
						EndDo
					Endif
					If (!Empty(cParcSest)).And.dbSeek(xFilial('SE2')+cPrefixo+(cAliasSF1)->F1_DOC+cParcSest+aFornece[5,3])
						R170Dupl(@Li,@Col)
					Endif				
					
					SE2->(dbGoto(nRecno))

				EndIf

				dbSelectArea('SE2')
				dbSetOrder(6)
				dbSkip()
			EndDo

			R170SayX(Li)
			Li += 1
			@ Li,000 PSAY __PrtThinLine()
			Li += 1
		Endif

		// Imprime Dados do Livros Fiscais.
		If cPaisloc=="BRA"
			dbSelectArea("SF3")
			dbSetOrder(4)
			dbSeek(xFilial("SF3")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE)
			If Found()
				Li += 1
				If Li >= 60
					Li := 1
				Endif
				//                                    1         2         3         4         5         6         7         8         9        10        11        12        13
				//                           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
				//                            xxx xxxx  99  99,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99       9,999,999,999.99

				@ Li,000 PSAY STR0030 //"----------------------------------------------- DEMONSTRATIVO DOS LIVROS FISCAIS ---------------------------------------------------"
				Li += 1
				@ Li,000 PSAY STR0031 //"|                               |   Operacoes c/ credito de Imposto   |            Operacoes s/ credito de Imposto                 |"
				Li += 1
				//                                 1         2         3         4         5         6         7         8         9        10        11        12        13
				//                       012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
				//                        xxxx xxxx  99   9,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99       9,999,999,999.99

				@ Li,000 PSAY STR0032 //"|    |CFOP |Alic| Valor Contable | Base de Calculo  |     Impuesto     |     Exentas      |      Otras       |     Observacion      |"
				Li += 1
				cLinha :=               "|    |     |    |                |                  |                  |                  |                  |                      |"
				While ! Eof() .And. xFilial("SF3")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE==F3_FILiAL+F3_CLiEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE

					If Val(Substr(SF3->F3_CFO,1,1))<5

						R170LdX(0,cLinha)
						//R170LdX(01,IIf(!Empty((cAliasSF1)->F1_ISS) .And. SF3->F3_TIPO == "S" ,STR0087,STR0088)) //"ISS"##"ICMS"
						R170LdX(01,IIf(!Empty((cAliasSF1)->F1_ISS) .And. SF3->F3_TIPO == "S" ,"ISS","ICMS")) //"ISS"##"ICMS"
						R170LdX(06,SF3->F3_CFO)
						R170LdX(12,Transform(SF3->F3_ALIQICM,"99"))
						R170LdX(17,Transform(SF3->F3_VALCONT,"@E 9,999,999,999.99"))
						R170LdX(34,Transform(SF3->F3_BASEICM,"@E 999,999,999,999.99"))
						R170LdX(53,Transform(SF3->F3_VALICM,"@E 999,999,999,999.99"))
						R170LdX(72,Transform(SF3->F3_ISENICM,"@E 999,999,999,999.99"))
						R170LdX(91,Transform(SF3->F3_OUTRICM,"@E 999,999,999,999.99"))
						R170SayX(Li)
						Li++
						If !EMPTY(SF3->F3_ICMSRET)
							R170LdX(0,cLinha)
							//R170LdX(109,STR0080) //"RET  "
							R170LdX(109,"RET  ") //"RET  "
							R170LdX(114,Transform(SF3->F3_ICMSRET,"@E 9,999,999,999.99"))
							R170SayX(Li)
							Li += 1
						Endif
						If !EMPTY(SF3->F3_ICMSCOM)
							R170LdX(0,cLinha)
							//R170LdX(109,STR0081) //"Compl"
							R170LdX(109,"Compl") //"Compl"
							R170LdX(114,Transform(SF3->F3_ICMSCOM,"@E 9,999,999,999.99"))
							R170SayX(Li)
							Li += 1
						Endif
						R170LdX(0,cLinha)
						//R170LdX(01,STR0086) //"IPI"
						R170LdX(01,"IPI") //"IPI"
						R170LdX(17,Transform(SF3->F3_VALCONT,"@E 9,999,999,999.99"))
						R170LdX(34,Transform(SF3->F3_BASEIPI,"@E 999,999,999,999.99"))
						R170LdX(53,Transform(SF3->F3_VALIPI,"@E 999,999,999,999.99"))
						R170LdX(72,Transform(SF3->F3_ISENIPI,"@E 999,999,999,999.99"))
						R170LdX(91,Transform(SF3->F3_OUTRIPI,"@E 999,999,999,999.99"))

						If ! Empty(SF3->F3_VALOBSE)
							//R170LdX(109,STR0082) //"OBS. "
							R170LdX(109,"OBS. ") //"OBS. "
							R170LdX(114,Transform(SF3->F3_VALOBSE,"@E 9,999,999,999.99"))
						Endif
						R170SayX(Li)
						Li += 1
					Endif

					dbSkip()
				End

			Endif

			Li += 1
			@ Li,000 PSAY __PrtThinLine()
			Li += 1
			@ Li,000 PSAY STR0059 //  "----------------------------------------------- DEMONSTRATIVO DOS DEMAIS IMPOSTOS ---------------------------------------------------"
			Li += 1
			@ Li,000 PSAY STR0060 //  "|                   | Base de Calculo  |     Imposto      |                                                                         |"
			Li += 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime Dados ref ao PIS                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SF1" .And. x[3]=="NF_BASEPS2"} ) )
				If !Empty((cAliasSF1)->(FieldPos(aRelImp[nScanPis,2])))
					nBasePis := (cAliasSF1)->(FieldGet((cAliasSF1)->(FieldPos(aRelImp[nScanPis,2]) ) ) )
				EndIf
			EndIf

			If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SF1" .And. x[3]=="NF_VALPS2"} ) )
				If !Empty((cAliasSF1)->(FieldPos(aRelImp[nScanPis,2])))
					nValPis := (cAliasSF1)->(FieldGet((cAliasSF1)->(FieldPos(aRelImp[nScanPis,2]) ) ) )
				EndIf
			EndIf

			If !Empty(nValPis)
				R170LdX(0,"|                   | Base de Calculo  |     Imposto      |")
				//R170LdX(01,STR0083) //"PIS APURACAO"
				R170LdX(01,"PIS APURACAO") //"PIS APURACAO"
				R170LdX(21,Transform(nBasePis,"@E 999,999,999,999.99"))
				R170LdX(40,Transform(nValPis,"@E 999,999,999,999.99"))
				R170SayX(Li)
				Li++
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime Dados ref ao COFINS                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SF1" .And. x[3]=="NF_BASECF2"} ) )
				If !Empty((cAliasSF1)->(FieldPos(aRelImp[nScanCof,2])))
					nBaseCof := (cAliasSF1)->(FieldGet((cAliasSF1)->(FieldPos(aRelImp[nScanCof,2]) ) ) )
				EndIf
			EndIf

			If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SF1" .And. x[3]=="NF_VALCF2"} ) )
				If !Empty((cAliasSF1)->(FieldPos(aRelImp[nScanCof,2])))
					nValCof := (cAliasSF1)->(FieldGet((cAliasSF1)->(FieldPos(aRelImp[nScanCof,2]) ) ) )
				EndIf
			EndIf

			If !Empty(nValCof)
				R170LdX(0,"|                   | Base de Calculo  |     Imposto      |")
				//R170LdX(01,STR0084) //"COFINS APURACAO"
				R170LdX(01,"COFINS APURACAO") 
				R170LdX(21,Transform(nBaseCof,"@E 999,999,999,999.99"))
				R170LdX(40,Transform(nValCof,"@E 999,999,999,999.99"))
				R170SayX(Li)
				Li++
			Endif

			@ Li,000 PSAY __PrtThinLine()
			If Li < 57
				Li := 57
			Endif
		Else
			aItens:=R170IMPI(cAliasSF1)
			If Len(aItens[1])>=0
				Li += 1
				If Li >= 60
					Li := 1
				Endif
				//                                     1         2         3         4         5         6         7         8         9        10        11        12        13
				//                           012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
				cLinha :=	    "|                  |                                          |     |        |                         |"
				@ Li,000 PSAY STR0042 //"-----------------------------------------------   RELACAO DE IMPOSTOS POR ITEM   ---------------------------------------------------"
				Li :=Li+1
				@ Li,000 PSAY STR0050  // |     PRODUTO      |               DESCRICAO                  | IMP |  ALIQ  |     BASE DE CALCULO     |      VALOR DO IMPOSTO
				Li += 1

				For nImp:=1 to Len(aItens)
					R170LdX(000,cLinha)
					R170LdX(001,aItens[nImp][1])
					R170LdX(022,aItens[nImp][2])
					R170LdX(064,aItens[nImp][3])
					R170LdX(070,Transform(NoRound(aItens[nImp][4]),PesqPict("SD1","D1_ALQIMP6")))
					R170LdX(080,Transform(aItens[nImp][5],PesqPict("SM2","M2_MOEDA1")))
					R170LdX(106,Transform(aItens[nImp][6],PesqPict("SM2","M2_MOEDA1")))
					R170SayX(Li)
					Li++
				Next
			Endif

			@ Li,000 PSAY __PrtThinLine()
			If Li < 57
				Li := 57
			Endif

		EndIf

		//                           1         2         3         4         5         6         7         8         9        10        11        12        13
		//                  123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
		@ Li,000 PSAY STR0033 //"------------------------------------------------------------------- VISTOS ---------------------------------------------------------"
		Li += 1
		@ Li,000 PSAY "|                               |                                |                                  |                              |"
		Li += 1
		@ Li,000 PSAY STR0034 //"| Recebimento  Fiscal           | Contabil/Custos                | Departamento Fiscal              | Administracao                |"
		Li += 1
		@ Li,000 PSAY __PrtThinLine()
		
		dbSelectArea(cAliasSF1)
		dbSkip()
		_lTES := .F.
		_lPrcErr := .F.
		_lQtdErr := .F.
		_QtdSal := .F.
	EndDo

	dbSelectArea("SF1")
	RetIndex("SF1")
	If File(cArqInd+ OrdBagExt())
		FErase(cArqInd+ OrdBagExt() )
	EndIf

	dbSelectArea("SD1")
	RetIndex("SD1")
	If File(cArqIndSD1+ OrdBagExt())
		FErase(cArqIndSD1+ OrdBagExt() )
	EndIf

	#IFDEF TOP
		If !lAuto
			dbSelectArea("QRYSF1")
			dbCloseArea()
		EndIf
	#ENDIF  

	If aReturn[5] == 1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()

RETURN(NIL)

/*/{Protheus.doc} Static Function R170CabX
	Imprime o cabecalho do Boletim. 
	@author HCCONSYS
	@since 13/04/2009
	@version 01
/*/

Static Function R170CabX() // R170Cabec()

	Local li         := 01
	Local aVencto    := {}
	Local aAuxCombo1 := {"N","D","B","I","P","C"}
	Local aCombo1	 := {STR0051,;	//"Normal"
		STR0052,;	//"Devoluçao"
		STR0053,;	//"Beneficiamento"
		STR0054,;	//"Compl.  ICMS"
		STR0055,;	//"Compl.  IPI"
		STR0056}	//"Compl. Preco/frete"
	Local cNumDoc := ""	

	// Faz manualmente porque nao chama a funcao Cabec()

	@ li,000 PSAY AvalImp(132)
	@ li,000 PSAY  ""
	@ Li,000 PSAY STR0035 +SubStr(cUsuario,7,15) + STR0036+Dtoc(dDataBase) //"Usuario: "###" Data Base: "
	Li += 1
	@ li,000 PSAY __PrtFatLine()
	Li += 1

	If (cAliasSF1)->F1_TIPO $ "DB"
		dbSelectArea("SE1")
		dbSetOrder(2)
		dbSeek(xFilial("SE1")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC)
		While !Eof() .And. E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM == xFilial("SE1")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC
			aADD(aVencto,E1_VENCREA)
			dbSkip()
		End
		@ li,000 PSAY OemToAnsi(STR0047)+SD1->D1_NUMSEQ+Space(66)+OemToAnsi(STR0048)+Dtoc(Date())+Space(14)+OemToAnsi(STR0049)+Time()   //  N. ## Data Ref. ### Hora Ref.
		li += 1
		@ li,000 PSAY STR0037 +dtoc((cAliasSF1)->F1_DTDIGIT)+IIF((cAliasSF1)->F1_TIPO=="D",STR0038," - ("+Alltrim(STR0053)+")") //"BOLETIM DE ENTRADA      Material recebido em: "###" - (Devolucao)"
		li += 1

		cCGC:=" - "
		cCGC+=Alltrim(RetTitle("A1_CGC"))
		cCGC+=": "
		cIE:=" "+AllTrim(RetTitle("A1_INSCR"))+" "
		cIEM:=" "+AllTrim(RetTitle("A1_INSCRIM"))+" "

		@ li,0 PSAY SM0->M0_NOME + "-" + SM0->M0_FILIAL + cCGC + SM0->M0_CGC
		Li += 1
		@ li,0 PSAY __PrtThinLine()
		Li += 1
		@ li,0 PSAY STR0039 //"Dados do Cliente                                                                                 | Nota Fiscal  | Emissao  | Vencto"
		Li += 1
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)
		cTipoNF	:= aCombo1[aScan(aAuxCombo1,(cAliasSF1)->F1_TIPO)]

		@ li,000 PSAY SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+SUBS(SA1->A1_NOME,1,40)
		@ li,069 PSAY "| "+(cAliasSF1)->F1_SERIE+" "+(cAliasSF1)->F1_DOC+"| "+(cAliasSF1)->F1_ESPECIE+"| "+CtipoNF
		@ li,110 PSAY "|"+DTOC((cAliasSF1)->F1_EMISSAO)
		@ li,121 PSAY IIf( Len(aVencto) == 1,"|"+DTOC(aVencto[1]),"|"+STR0040 ) //"Diversos"
		Li += 1
		@ li,000 PSAY SA1->A1_END
		@ li,088 PSAY STR0041
		@ li,115 PSAY transform(((cAliasSF1)->F1_VALBRUT),PesqPict("SF1","F1_VALBRUT")) //"| Valor Total   "
		Li += 1
		@ li,000 PSAY SA1->A1_MUN+" "+SA1->A1_EST+" "+Transform(SA1->A1_CGC,PicPesFJ(If(Len(AllTrim(SA1->A1_CGC))<14,"F","J")))
	Else
		dbSelectArea("SE2")
		dbSetOrder(6)
		dbSeek(xFilial("SE2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC)
		While !Eof() .And. E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM == xFilial("SE2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC
			aADD(aVencto,E2_VENCTO)
			dbSkip()
		End
		@ li,000 PSAY OemToAnsi(STR0047)+SD1->D1_NUMSEQ+Space(68)+OemToAnsi(STR0048)+Dtoc(Date())+Space(14)+OemToAnsi(STR0049)+Time()   // N. ### Data Impressao ### Hora Ref.
		li += 1
		@ li,000 PSAY STR0037 +Dtoc((cAliasSF1)->F1_DTDIGIT) //"BOLETIM DE ENTRADA      Material recebido em: "
		li += 1

		cCGC:=" - "
		cCGC+=Alltrim(RetTitle("A1_CGC"))
		cCGC+=": "
		cIE:=" "+AllTrim(RetTitle("A1_INSCR"))+" "
		cIEM:=" "+AllTrim(RetTitle("A1_INSCRIM"))+" "

		@ li,0 PSAY SM0->M0_NOME + "-" + SM0->M0_FILIAL + cCGC + SM0->M0_CGC //" - CGC.: "
		li += 1
		@ li,000 PSAY __PrtThinLine()
		li += 1
		@ li,0 PSAY If(cPaisLoc=="BRA",STR0043,STR0057) //"Dados do Fornecedor                                                                              | Nota Fiscal  | Emissao  | Vencto"
		li += 1
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(XFilial("SA2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)
		cTipoNF	:= aCombo1[aScan(aAuxCombo1,(cAliasSF1)->F1_TIPO)]
		cNumDoc := If(cPaisLoc=="BRA",(cAliasSF1)->F1_DOC,PadR((cAliasSF1)->F1_DOC,13,""))

		@ li,000 PSAY SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+SubStr(SA2->A2_NOME,1,40)
		@ li,069 PSAY "| "+(cAliasSF1)->F1_SERIE+" "+cNumDoc+"| "+(cAliasSF1)->F1_ESPECIE+"|"+CtipoNF
		@ li,If(cPaisLoc=="BRA",110,114) PSAY "|"+DTOC((cAliasSF1)->F1_EMISSAO)
		@ li,If(cPaisLoc=="BRA",121,125) PSAY "|"+IIf( Len(aVencto) == 1, DTOC(aVencto[1]),STR0040 ) //"Diversos"
		li += 1
		@ li,000 PSAY SA2->A2_END
		@ li,088 PSAY STR0041
		@ li,115 PSAY transform(((cAliasSF1)->F1_VALBRUT),PesqPict("SF1","F1_VALBRUT")) //"| Valor Total   "
		li += 1
		@ li,000 PSAY SA2->A2_MUN+" "+SA2->A2_EST+" "+Substr(cCGC,4,Len(cCGC)-3)+" "+If(cPaisLoc<>"BRA",Transform(SA2->A2_CGC,PesqPict("SA2","A2_CGC")),Transform(SA2->A2_CGC,PicPesFJ(If(Len(AllTrim(SA2->A2_CGC))<14,"F","J"))))+" "+cIE+" "+SA2->A2_INSCR+" "+cIEM+" "+SA2->A2_INSCRM //" CGC: "###"  I.E: "###"  I.M. "

		// Acrescentado informacoes referente aos dados bancarios do Fornecedor
		// HCCONSYS
		li++                      
		If !Empty(SA2->A2_BANCO)
			dbSelectArea("SA6")
			SA6->(dbSeek(xFilial("SA6")+SA2->A2_BANCO))
			dbSelectArea("SA2")
			@ li,000 PSAY "Banco: " 	+ Alltrim(SA2->A2_BANCO) 		+ "  " 	+ Alltrim(SA6->A6_NOME) 
			@ li,045 PSAY "Agencia: " 	+ Alltrim(SA2->A2_AGENCIA) 	+ Iif(!Empty(SA2->A2_DIGAG),"-" 	+ SA2->A2_DIGAG,"")
			@ li,070 PSAY "Conta  : " 	+ Alltrim(SA2->A2_NUMCON)  	+ Iif(!Empty(SA2->A2_DIGCTA),"-" 	+ SA2->A2_DIGCTA,"")
			
		EndIf 
		
	EndIf
	li += 1

Return( li )

Static Function R170LdX(nPos,cTexto) // R170Load(nPos,cTexto)

	cAuxLinha := Substr(cAuxLinha,1,nPos)+cTexto+Substr(cAuxLinha,nPos+Len(cTexto)+1,132-nPos+Len(cTexto))

Return

Static Function R170SayX(nLinha) // R170Say(nLinha)

	@ nLinha,000 PSAY cAuxLinha
	cAuxLinha := SPACE(132)

Return

/*/{Protheus.doc} Static Function R170IMPT
	Faz a somatoria dos impostos da nota. Retornando um array com todas as informacoes a serem impressas
	@author HCCONSYS
	@since 13/04/2009
	@version 01
/*/

Static Function R170IMPT(cAliasSF1)

	Local aArea    := {}
	Local aAreaSD1 := {}
	Local aImp     := {}
	Local aImpostos:= {}
	Local nImpos:= 0
	Local nBase := 0
	Local nY,cCampImp,cCampBas

	aArea:=GetArea()


	dbSelectArea("SD1")
	aAreaSD1:=GetArea()

	dbSetOrder(3)

	cSeek:=(xFilial("SD1")+Dtos((cAliasSF1)->F1_EMISSAO)+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+;
		(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)

	If dbSeek(cSeek)
		While cSeek==xFilial("SD1")+dtos(D1_EMISSAO)+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
			aImpostos:=TesImpInf(D1_TES)
			For nY:=1 to Len(aImpostos)
				cCampImp:="SD1->"+(aImpostos[nY][2])
				cCampBas:="SD1->"+(aImpostos[nY][7])
				nImpos+=&cCampImp
				nBase +=&cCampBas
			Next
			dbSkip()
		Enddo
	EndIf

	RestArea(aAreaSD1)
	RestArea(aArea)

	AADD(aImp,nBase)
	AADD(aImp,nImpos)

Return aImp

/*/{Protheus.doc} Static Function R170IMPI
	Retorna array com lista de impostos por item
	@author HCCONSYS
	@since 13/04/2009
	@version 01
/*/

Static Function R170IMPI(cAliasSF1)

	Local aArea    := {}
	Local aAreaSD1 := {}
	Local aImp     := {}
	Local aRet     := {}
	Local nY

	aArea:=GetArea()


	dbSelectArea("SD1")
	aAreaSD1:=GetArea()

	dbSetOrder(3)

	cSeek:=(xFilial("SD1")+Dtos((cAliasSF1)->F1_EMISSAO)+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+;
		(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)

	If dbSeek(cSeek)
		While cSeek==xFilial("SD1")+dtos(D1_EMISSAO)+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
			aImp:=TesImpInf(D1_TES)

			// Pega a descricao do produto
			dbSelectArea("SB1")
			aAreaSB1:=GetArea()
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+SD1->D1_COD)
			cDescProd:=B1_DESC
			RestArea(aAreaSB1)

			dbSelectArea("SD1")
			For nY:=1 to Len(aImp)
				AADD(aRet,{SD1->D1_COD,cDescProd,aImp[nY][1],&("SD1->"+aImp[nY][10]),&("SD1->"+(aImp[nY][7])),&("SD1->"+(aImp[nY][2]))})
			Next
			dbSkip()
		Enddo
	EndIf

	If Len(aRet)<= 0
		AADD(aRet,{"" ,"" ,"" ,0 ,0 ,0})
	EndIf

	RestArea(aAreaSD1)
	RestArea(aArea)

Return aRet

/*/{Protheus.doc} Static Function R170Dupl
	Imprime o Desdobramento de duplicatas
	@author HCCONSYS
	@since 13/04/2009
	@version 01
/*/

Static Function R170DUPL(Li,Col)

	dbSelectArea("SE2")

	If Li >= 60
		Li := 1
		@ Li,000 PSAY STR0026 //"--------------------------------------------------- DESDOBRAMENTO DE DUPLICATAS ----------------------------------------------------"
		Li := Li + 1
		@ Li,000 PSAY STR0027 //"Ser|Titulo       | Vencto   |Valor do Titulo  | Natureza          ||Ser|Titulo       | Vencto   |Valor do Titulo  | Natureza        "
		Li := Li + 1
	Endif

	R170LdX(Col,SE2->E2_PREFIXO)
	R170LdX(Col+4,SE2->E2_NUM)
	R170LdX(Col+14,SE2->E2_PARCELA)
	R170LdX(Col+18,dtoc(SE2->E2_VENCTO))
	R170LdX(Col+29,Transform(SE2->E2_VALOR,"@E 99,999,999,999.99"))
	R170LdX(Col+48,SE2->E2_NATUREZ)

	If Col == 0
		Col := 68
	Else
		Col := 0
		R170SayX(Li)
		R170LdX(0,cLinha)
		Li := Li + 1
	EndIf

Return

/*/{Protheus.doc} Static Function AjustaSX1
	Ajusta perguntas do SX1
	@author HCCONSYS
	@since 13/04/2009
	@version 01
/*/

Static Function AjustaSX1()

	Local aHelpPor07 := {'Ordem de Impressao ', '', ''}
	Local aHelpEsp07 := {'Orden de impresion ', '', ''}
	Local aHelpEng07 := {'Print Order        ', '', ''}
	Local aHelpPor08 := {'Se voce escolher imprimir o Armazem,  ', 'a descricao do Produto sera'      , 'reduzida em duas posicoes.'}
	Local aHelpEsp08 := {'Si usted elige imprimir el Deposito,  ', 'la descripcion del producto sera ', 'reducida en dos posiciones.'}
	Local aHelpEng08 := {'If you choose to print the Warehouse, ', 'the product description will be'  , 'reduced in two positions.'}

	PutSX1Help("P.MTR17007.", aHelpPor07, aHelpEng07, aHelpEsp07)

	PutSx1('MTR170','08','Imprime Armazem    ?','Imprime Deposito   ?','Show  Warehouse    ?','mv_ch8','N',2,0,2,'C','','','','','mv_par08','Sim','Si','Yes','','Nao','No','No','','','','','','','','','', aHelpPor08, aHelpEsp08, aHelpEng08)

	// Ajusta a opcao do tipo
	dbSelectArea("SX1")
	If dbSeek("MTR17005")
		RecLock("SX1",.F.)
		Replace X1_DEF03   With "Entidade Contab"
		Replace X1_DEFSPA3 With "Ente Contable"
		Replace X1_DEFENG3 With "Account.Entity"
		MsUnLock()
	EndIf

Return