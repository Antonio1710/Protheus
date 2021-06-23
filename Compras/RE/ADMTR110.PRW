#INCLUDE "MATR110.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} User Function ADMTR110
	Pedido de Compras / Autorizacao de Entrega Especifico Adoro para atender solicitacao Rosangela
	@type  Function
	@author Alexandre Inacio Lemes
	@since 06/09/2006
	@version version
	@history Chamado T.I    - Adriana Oliveira - SEM DATA   - Sem detalhamento  
	@history Chamado T.I    - Luciano Mafra    - 27/11/2013 - Sem detalhamento  
	@history Chamado 050939 - Everson          - 16/08/2019 - Remover colunas de valor unitário. total e IPI e acrescentar o complemento da descrição do produto no relatório  u_AD110R3.
	@history Chamado 057146 - Everson 		   - 13/04/2020 - Adicionar hora e data de geração do relatório.
	/*/

USER Function ADMTR110( cAlias, nReg, nOpcx )

	Local oReport

	PRIVATE lAuto := (nReg!=Nil)
	PRIVATE cPerg := PADR("MTR110",10," ")  

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Pedido de Compras / Autorizacao de Entrega Especifico Adoro para atender solicitacao Rosangela')

	If FindFunction("TRepInUse") .And. TRepInUse()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Interface de impressao                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:= ReportDef(nReg, nOpcx)
		oReport:PrintDialog()
	Else
		u_AD110R3( cAlias, nReg, nOpcx )
	EndIf

Return

Static Function ReportDef(nReg,nOpcx)

	Local cTitle   := STR0003 // "Emissao dos Pedidos de Compras ou Autorizacoes de Entrega"
	Local oReport
	Local oSection1
	Local oSection2                                                   
	cPerg := PADR("MTR110",10," ")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01               Do Pedido                             ³
	//³ mv_par02               Ate o Pedido                          ³
	//³ mv_par03               A partir da data de emissao           ³
	//³ mv_par04               Ate a data de emissao                 ³
	//³ mv_par05               Somente os Novos                      ³
	//³ mv_par06               Campo Descricao do Produto    	     ³
	//³ mv_par07               Unidade de Medida:Primaria ou Secund. ³
	//³ mv_par08               Imprime ? Pedido Compra ou Aut. Entreg³
	//³ mv_par09               Numero de vias                        ³
	//³ mv_par10               Pedidos ? Liberados Bloqueados Ambos  ³
	//³ mv_par11               Impr. SC's Firmes, Previstas ou Ambas ³
	//³ mv_par12               Qual a Moeda ?                        ³
	//³ mv_par13               Endereco de Entrega                   ³
	//³ mv_par14               todas ou em aberto ou atendidos       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AjustaSX1()
	Pergunte(cPerg,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do componente de impressao                                      ³
	//³                                                                        ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= TReport():New("MATR110",cTitle,"MTR110", {|oReport| ReportPrint(oReport,nReg,nOpcx)},STR0001+" "+STR0002)
	oReport:SetPortrait()
	oReport:HideParamPage()
	oReport:HideHeader()
	oReport:HideFooter()
	oReport:SetTotalInLine(.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao da secao utilizada pelo relatorio                               ³
	//³                                                                        ³
	//³TRSection():New                                                         ³
	//³ExpO1 : Objeto TReport que a secao pertence                             ³
	//³ExpC2 : Descricao da seçao                                              ³
	//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
	//³        sera considerada como principal para a seção.                   ³
	//³ExpA4 : Array com as Ordens do relatório                                ³
	//³ExpL5 : Carrega campos do SX3 como celulas                              ³
	//³        Default : False                                                 ³
	//³ExpL6 : Carrega ordens do Sindex                                        ³
	//³        Default : False                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao da celulas da secao do relatorio                                ³
	//³                                                                        ³
	//³TRCell():New                                                            ³
	//³ExpO1 : Objeto TSection que a secao pertence                            ³
	//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
	//³ExpC3 : Nome da tabela de referencia da celula                          ³
	//³ExpC4 : Titulo da celula                                                ³
	//³        Default : X3Titulo()                                            ³
	//³ExpC5 : Picture                                                         ³
	//³        Default : X3_PICTURE                                            ³
	//³ExpC6 : Tamanho                                                         ³
	//³        Default : X3_TAMANHO                                            ³
	//³ExpL7 : Informe se o tamanho esta em pixel                              ³
	//³        Default : False                                                 ³
	//³ExpB8 : Bloco de código para impressao.                                 ³
	//³        Default : ExpC2                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oSection1:= TRSection():New(oReport,STR0102,{"SC7","SM0","SA2"},/*aOrdem*/) //"| P E D I D O  D E  C O M P R A S"
	oSection1:SetLineStyle()
	oSection1:SetReadOnly()

	TRCell():New(oSection1,"M0_NOMECOM","SM0",STR0087      ,/*Picture*/,49,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_NOME"   ,"SA2",/*Titulo*/   ,/*Picture*/,40,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_COD"    ,"SA2",/*Titulo*/   ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_LOJA"   ,"SA2",/*Titulo*/   ,/*Picture*/,04,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_ENDENT" ,"SM0",STR0088      ,/*Picture*/,48,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_END"    ,"SA2",/*Titulo*/   ,/*Picture*/,40,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_BAIRRO" ,"SA2",/*Titulo*/   ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_CEPENT" ,"SM0",STR0089      ,/*Picture*/,10,/*lPixel*/,{|| Trans(SM0->M0_CEPENT,PesqPict("SA2","A2_CEP")) })
	TRCell():New(oSection1,"M0_CIDENT" ,"SM0",STR0090      ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_ESTENT" ,"SM0",STR0091      ,/*Picture*/,11,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_MUN"    ,"SA2",/*Titulo*/   ,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_EST"    ,"SA2",/*Titulo*/   ,/*Picture*/,02,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_CEP"    ,"SA2",/*Titulo*/   ,/*Picture*/,08,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_CGC"    ,"SA2",/*Titulo*/   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_TEL"    ,"SM0",STR0092      ,/*Picture*/,14,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_FAX"    ,"SM0",STR0093      ,/*Picture*/,34,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"FONE"      ,"   ",STR0094      ,/*Picture*/,25,/*lPixel*/,{|| "("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15)})
	TRCell():New(oSection1,"FAX"       ,"   ","FAX"        ,/*Picture*/,25,/*lPixel*/,{|| "("+Substr(SA2->A2_DDD,1,3)+") "+SubStr(SA2->A2_FAX,1,15)})
	TRCell():New(oSection1,"INSCR"     ,"   ",If( cPaisLoc$"ARG|POR|EUA",space(11) , STR0095 ),/*Picture*/,18,/*lPixel*/,{|| If( cPaisLoc$"ARG|POR|EUA",space(18), SA2->A2_INSCR ) })
	TRCell():New(oSection1,"M0_CGC"    ,"SM0",STR0096      ,/*Picture*/,18,/*lPixel*/,{|| Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC")) })

	If cPaisLoc == "BRA"
		TRCell():New(oSection1,"M0IE"  ,"   ",STR0041      ,/*Picture*/,18,/*lPixel*/,{|| InscrEst()})
	EndIf

	oSection1:Cell("A2_BAIRRO"):SetCellBreak()
	oSection1:Cell("A2_CGC"   ):SetCellBreak()
	oSection1:Cell("INSCR"    ):SetCellBreak()

	oSection2:= TRSection():New(oSection1,STR0103,{"SC7","SB1"},/*aOrdem*/)

	oSection2:SetCellBorder("ALL",,,.T.)
	oSection2:SetCellBorder("RIGHT")
	oSection2:SetCellBorder("LEFT")

	TRCell():New(oSection2,"C7_ITEM"    ,"SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"C7_PRODUTO" ,"SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"DESCPROD"   ,"   ",STR0097   ,/*Picture*/,33,/*lPixel*/, {|| cDescPro })
	TRCell():New(oSection2,"C7_UM"      ,"SC7",STR0115   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"C7_SEGUM"   ,"SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"C7_QUANT"   ,"SC7",/*Titulo*/,PesqPictQt("C7_QUANT",13),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"C7_QTSEGUM" ,"SC7",/*Titulo*/,PesqPictQt("C7_QUANT",13),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"PRECO"      ,"   ",STR0098,PesqPict("SC7","C7_PRECO",16, mv_par12),16/*Tamanho*/,/*lPixel*/,{|| nVlUnitSC7 })
	TRCell():New(oSection2,"C7_IPI"     ,"SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"TOTAL"      ,"   ",STR0099,PesqPict("SC7","C7_TOTAL",16,mv_par12),16/*Tamanho*/,/*lPixel*/,{|| nValTotSC7 })
	TRCell():New(oSection2,"C7_DATPRF"  ,"SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"C7_CC"      ,"SC7",/*Titulo*/,PesqPict("SC7","C7_CC",20),IIf(cPaisLoc <> "BRA" ,32,21)/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"C7_NUMSC"   ,"SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"OPCC"       ,"   ",STR0100   ,/*Picture*/,IIf(cPaisLoc <> "BRA",47,46),/*lPixel*/,{|| cOPCC })

	oSection2:Cell("DESCPROD"):SetLineBreak()

Return(oReport)

Static Function ReportPrint(oReport,nReg,nOpcX)

	Local oSection1   := oReport:Section(1)
	Local oSection2   := oReport:Section(1):Section(1)

	Local aRecnoSave  := {}
	Local aPedido     := {}
	Local aPedMail    := {}
	Local aValIVA     := {}

	Local cNumSC7     := Len(SC7->C7_NUM)
	Local cCondicao   := ""
	Local cFiltro     := ""
	Local cComprador  := ""
	LOcal cAlter	  := ""
	Local cAprov	  := ""
	Local cTest       := ""
	Local cSolic      := ""
	Local cTipoSC7    := ""
	Local cCondBus    := ""
	Local cMensagem   := ""
	Local cVar        := ""

	Local lNewAlc	  := .F.
	Local lLiber      := .F.

	Local nRecnoSC7   := 0
	Local nRecnoSM0   := 0
	Local nX          := 0
	Local nY          := 0
	Local nVias       := 0
	Local nTxMoeda    := 0
	Local nPageWidth  := 2290 // oReport:PageWidth()
	Local nPrinted    := 0
	Local nValIVA     := 0
	Local nTotIpi	  := 0
	Local nTotIcms	  := 0
	Local nTotDesp	  := 0
	Local nTotFrete	  := 0
	Local nTotalNF	  := 0
	Local nTotSeguro  := 0
	Local nLinPC	  := 0
	Local nLinObs     := 0
	Local nDescProd   := 0
	Local nTotal      := 0
	Local nTotMerc    := 0
	Local nPagina     := 0
	Local nOrder      := 1
	Local cUserId     := RetCodUsr()
	Local cCont       := Nil
	Local lImpri      := .F.

	Private cDescPro  := ""
	Private cOPCC     := ""
	Private	nVlUnitSC7:= 0
	Private nValTotSC7:= 0

	Private cObs01    := ""
	Private cObs02    := ""
	Private cObs03    := ""
	Private cObs04    := ""

	dbSelectArea("SC7")

	If lAuto  
		dbSelectArea("SC7")
		dbGoto(nReg)
		mv_par01 := SC7->C7_NUM
		mv_par02 := SC7->C7_NUM
		mv_par03 := SC7->C7_EMISSAO
		mv_par04 := SC7->C7_EMISSAO
		mv_par05 := Eval({|| cCont:=ChkPerg110(cUserId,cPerg,"05"),If(cCont == Nil,2,cCont) })
		mv_par08 := Eval({|| cCont:=ChkPerg110(cUserId,cPerg,"08"),If(cCont == Nil,C7_TIPO,cCont) })
		mv_par09 := Eval({|| cCont:=ChkPerg110(cUserId,cPerg,"09"),If(cCont == Nil,1,cCont) })
		mv_par10 := Eval({|| cCont:=ChkPerg110(cUserId,cPerg,"10"),If(cCont == Nil,3,cCont) }) 
		mv_par11 := Eval({|| cCont:=ChkPerg110(cUserId,cPerg,"11"),If(cCont == Nil,3,cCont) }) 
		mv_par14 := Eval({|| cCont:=ChkPerg110(cUserId,cPerg,"14"),If(cCont == Nil,1,cCont) }) 	
	Else         
		MakeAdvplExpr(oReport:uParam)
		
		cCondicao := 'C7_FILIAL=="'       + xFilial("SC7") + '".And.'
		cCondicao += 'C7_NUM>="'          + mv_par01       + '".And.C7_NUM<="'          + mv_par02 + '".And.'
		cCondicao += 'Dtos(C7_EMISSAO)>="'+ Dtos(mv_par03) +'".And.Dtos(C7_EMISSAO)<="' + Dtos(mv_par04) + '"'
		
		oReport:Section(1):SetFilter(cCondicao,IndexKey())
	EndIf

	If SC7->C7_TIPO == 1
		If ( cPaisLoc$"ARG|POR|EUA" )
			cCondBus := "1"+StrZero(Val(mv_par01),6)
			nOrder	 := 10
		Else
			cCondBus := mv_par01
			nOrder	 := 1
		EndIf
	Else
		cCondBus := "2"+StrZero(Val(mv_par01),6)
		nOrder	 := 10
	EndIf

	If mv_par14 == 2
		cFiltro := "SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)"
	Elseif mv_par14 == 3
		cFiltro := "SC7->C7_QUANT > SC7->C7_QUJE"
	EndIf

	TRPosition():New(oSection2,"SB1",1,{ || xFilial("SB1") + SC7->C7_PRODUTO })
	TRPosition():New(oSection2,"SB5",1,{ || xFilial("SB5") + SC7->C7_PRODUTO })

	// Executa o CodeBlock com o PrintLine da Sessao 1 toda vez que rodar o oSection1:Init()   ³

	oReport:onPageBreak( { || nPagina++ , nPrinted := 0 , CabecPCxAE(oReport,oSection1,nVias,nPagina) })

	oReport:SetMeter(SC7->(LastRec()))
	dbSelectArea("SC7")
	dbSetOrder(nOrder)
	dbSeek(xFilial("SC7")+cCondBus,.T.)

	oSection2:Init()

	cNumSC7 := SC7->C7_NUM

	While !oReport:Cancel() .And. !SC7->(Eof()) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_NUM >= mv_par01 .And. SC7->C7_NUM <= mv_par02
		
		If (SC7->C7_CONAPRO == "B" .And. mv_par10 == 1) .Or.;
			(SC7->C7_CONAPRO <> "B" .And. mv_par10 == 2) .Or.;
			(SC7->C7_EMITIDO == "S" .And. mv_par05 == 1) .Or.;
			((SC7->C7_EMISSAO < mv_par03) .Or. (SC7->C7_EMISSAO > mv_par04)) .Or.;
			(SC7->C7_TIPO == 1 .And. mv_par08 == 2) .Or.;
			(SC7->C7_TIPO == 2 .And. mv_par08 == 1) .Or. !MtrAValOP(mv_par11, "SC7") .Or.;
			(SC7->C7_QUANT > SC7->C7_QUJE .And. mv_par14 == 3) .Or.;
			((SC7->C7_QUANT - SC7->C7_QUJE <= 0 .Or. !Empty(SC7->C7_RESIDUO)) .And. mv_par14 == 2 )
			
			dbSelectArea("SC7")
			dbSkip()
			Loop
		Endif
		
		If oReport:Cancel()
			Exit
		EndIf
		
		MaFisEnd()
		R110FIniPC(SC7->C7_NUM,,,cFiltro)
		//MaFisIniPC(SC7->C7_NUM,,,cFiltro)
		
		cObs01    := " "
		cObs02    := " "
		cObs03    := " "
		cObs04    := " "
		
		// Roda a impressao conforme o numero de vias informado no mv_par09 
		
		For nVias := 1 to mv_par09
			
			// Dispara a cabec especifica do relatorio.                     
			
			oReport:EndPage()
			
			nPagina  := 0
			nPrinted := 0
			nTotal   := 0
			nTotMerc := 0
			nDescProd:= 0
			nLinObs  := 0
			nRecnoSC7:= SC7->(Recno())
			cNumSC7  := SC7->C7_NUM
			aPedido  := {SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_EMISSAO,SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_TIPO}
			
			While !oReport:Cancel() .And. !SC7->(Eof()) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_NUM == cNumSC7
				
				If (SC7->C7_CONAPRO == "B" .And. mv_par10 == 1) .Or.;
					(SC7->C7_CONAPRO <> "B" .And. mv_par10 == 2) .Or.;
					(SC7->C7_EMITIDO == "S" .And. mv_par05 == 1) .Or.;
					((SC7->C7_EMISSAO < mv_par03) .Or. (SC7->C7_EMISSAO > mv_par04)) .Or.;
					(SC7->C7_TIPO == 1 .And. mv_par08 == 2) .Or.;
					(SC7->C7_TIPO == 2 .And. mv_par08 == 1) .Or. !MtrAValOP(mv_par11, "SC7") .Or.;
					(SC7->C7_QUANT > SC7->C7_QUJE .And. mv_par14 == 3) .Or.;
					((SC7->C7_QUANT - SC7->C7_QUJE <= 0 .Or. !Empty(SC7->C7_RESIDUO)) .And. mv_par14 == 2 )
					dbSelectArea("SC7")
					dbSkip()
					Loop
				Endif
				
				If oReport:Cancel()
					Exit
				EndIf
				
				oReport:IncMeter()
				
				If oReport:Row() > oReport:LineHeight() * 100
					oReport:Box( oReport:Row(),010,oReport:Row() + oReport:LineHeight() * 3, nPageWidth )
					oReport:SkipLine()
					oReport:PrintText(STR0101,, 050 ) // Continua na Proxima pagina ....
					oReport:EndPage()
				EndIf
				
				// Salva os Recnos do SC7 no aRecnoSave para marcar reimpressao.
				
				If Ascan(aRecnoSave,SC7->(Recno())) == 0
					AADD(aRecnoSave,SC7->(Recno()))
				Endif
				
				// Inicializa o descricao do Produto conf. parametro digitado.
				
				cDescPro :=  ""
				If Empty(mv_par06)
					mv_par06 := "B1_DESC"
				EndIf
				
				If AllTrim(mv_par06) == "B1_DESC"
					SB1->(dbSetOrder(1))
					SB1->(dbSeek( xFilial("SB1") + SC7->C7_PRODUTO ))
					cDescPro := SB1->B1_DESC
				ElseIf AllTrim(mv_par06) == "B5_CEME"
					SB5->(dbSetOrder(1))
					If SB5->(dbSeek( xFilial("SB5") + SC7->C7_PRODUTO ))
						cDescPro := SB5->B5_CEME
					EndIf
				ElseIf AllTrim(mv_par06) == "C7_DESCRI"
					cDescPro := SC7->C7_DESCRI
				EndIf
				
				If Empty(cDescPro)
					SB1->(dbSetOrder(1))
					SB1->(dbSeek( xFilial("SB1") + SC7->C7_PRODUTO ))
					cDescPro := SB1->B1_DESC
				EndIf
				
				SA5->(dbSetOrder(1))
				If SA5->(dbSeek(xFilial("SA5")+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_PRODUTO)) .And. !Empty(SA5->A5_CODPRF)
					cDescPro := cDescPro + " ("+Alltrim(SA5->A5_CODPRF)+")"
				EndIf
				
				If SC7->C7_DESC1 != 0 .Or. SC7->C7_DESC2 != 0 .Or. SC7->C7_DESC3 != 0
					nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
				Else
					nDescProd+=SC7->C7_VLDESC
				Endif 

				//Inicializacao da Observacao do Pedido.                       
				
				If !Empty(SC7->C7_OBS) .And. nLinObs < 5
					nLinObs++
					cVar:="cObs"+StrZero(nLinObs,2)
					Eval(MemVarBlock(cVar),SC7->C7_OBS)
				Endif
				
				nTxMoeda   := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
				nValTotSC7 := xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda)
				
				nTotal     := nTotal + SC7->C7_TOTAL
				nTotMerc   := MaFisRet(,"NF_TOTAL")
				
				If MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM) .And. !Empty(SC7->C7_SEGUM)
					oSection2:Cell("C7_SEGUM"  ):Enable()
					oSection2:Cell("C7_QTSEGUM"):Enable()
					oSection2:Cell("C7_UM"     ):Disable()
					oSection2:Cell("C7_QUANT"  ):Disable()
					nVlUnitSC7 := xMoeda((SC7->C7_TOTAL/SC7->C7_QTSEGUM),SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda)
				Else
					oSection2:Cell("C7_SEGUM"  ):Disable()
					oSection2:Cell("C7_QTSEGUM"):Disable()
					oSection2:Cell("C7_UM"     ):Enable()
					oSection2:Cell("C7_QUANT"  ):Enable()
					nVlUnitSC7 := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda)
				EndIf
				
				If cPaisLoc <> "BRA" .Or. mv_par08 == 2
					oSection2:Cell("C7_IPI" ):Disable()
				EndIf
				
				If mv_par08 == 1
					oSection2:Cell("OPCC"):Disable()
				Else
					oSection2:Cell("C7_CC"):Disable()
					oSection2:Cell("C7_NUMSC"):Disable()
					If !Empty(SC7->C7_OP)
						cOPCC := STR0065 + " " + SC7->C7_OP
					ElseIf !Empty(SC7->C7_CC)
						cOPCC := STR0066 + " " + SC7->C7_CC
					EndIf
				EndIf
				
				oSection2:PrintLine()
				
				nPrinted ++
				lImpri  := .T.
				dbSelectArea("SC7")
				dbSkip()
				
			EndDo
			
			SC7->(dbGoto(nRecnoSC7))
			
			If oReport:Row() > oReport:LineHeight() * 70
				
				oReport:Box( oReport:Row(),010,oReport:Row() + oReport:LineHeight() * 3, nPageWidth )
				oReport:SkipLine()
				oReport:PrintText(STR0101,, 050 ) // Continua na Proxima pagina ....
				
				// Dispara a cabec especifica do relatorio.                     
				
				oReport:EndPage()
				oReport:PrintText(" ",1992 , 010 ) // Necessario para posicionar Row() para a impressao do Rodape
				
				oReport:Box( 280,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
				
			Else
				oReport:Box( oReport:Row(),oReport:Col(),oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			EndIf
			
			oReport:Box( 1990 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			oReport:Box( 2080 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			oReport:Box( 2200 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			oReport:Box( 2320 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			
			oReport:Box( 2200 , 1080 , 2320 , 1400 ) // Box da Data de Emissao
			oReport:Box( 2320 ,  010 , 2406 , 1220 ) // Box do Reajuste
			oReport:Box( 2320 , 1220 , 2460 , 1750 ) // Box do IPI e do Frete
			oReport:Box( 2320 , 1750 , 2460 , nPageWidth ) // Box do ICMS Despesas e Seguro
			oReport:Box( 2406 ,  010 , 2700 , 1220 ) // Box das Observacoes
			
			cMensagem:= Formula(C7_MSG)
			If !Empty(cMensagem)
				oReport:SkipLine()
				oReport:PrintText(PadR(cMensagem,129), , oSection2:Cell("DESCPROD"):ColPos() )
			Endif
			
			oReport:PrintText( STR0007 /*"D E S C O N T O S -->"*/ + " " + ;
			TransForm(SC7->C7_DESC1,"999.99" ) + " %    " + ;
			TransForm(SC7->C7_DESC2,"999.99" ) + " %    " + ;
			TransForm(SC7->C7_DESC3,"999.99" ) + " %    " + ;
			TransForm(xMoeda(nDescProd,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) , PesqPict("SC7","C7_VLDESC",14, mv_par12) ),;
			2022 , 050 )
			
			oReport:SkipLine()
			oReport:SkipLine()
			oReport:SkipLine()
			
			// Posiciona o Arquivo de Empresa SM0.                          
			// Imprime endereco de entrega do SM0 somente se o MV_PAR13 =" "
			// e o Local de Cobranca :                                      
			
			SM0->(dbSetOrder(1))
			nRecnoSM0 := SM0->(Recno())
			SM0->(dbSeek(SUBS(cNumEmp,1,2)+SC7->C7_FILENT))
			
			If Empty(MV_PAR13) //"Local de Entrega  : "
				oReport:PrintText( STR0008 + ALLTRIM(SM0->M0_ENDENT) +"  "+ ALLTRIM(SM0->M0_CIDENT) +"  - "+ ALLTRIM(SM0->M0_ESTENT) +" - "+STR0009+" "+Trans(Alltrim(SM0->M0_CEPENT),PesqPict("SA2","A2_CEP")),, 050 )  // RICARDO LIMA - 23/11/17 | AJUSTE DE LAYOUT
			Else
				oReport:PrintText(STR0008 + mv_par13,, 050 ) //"Local de Entrega  : " imprime o endereco digitado na pergunte
			Endif
			SM0->(dbGoto(nRecnoSM0))
			oReport:PrintText(STR0010 + SM0->M0_ENDCOB+"  "+SM0->M0_CIDCOB+"  - "+SM0->M0_ESTCOB+" - "+STR0009+" "+Trans(Alltrim(SM0->M0_CEPCOB),PesqPict("SA2","A2_CEP")),, 050 )
			
			oReport:SkipLine()
			oReport:SkipLine()
			
			SE4->(dbSetOrder(1))
			SE4->(dbSeek(xFilial("SE4")+SC7->C7_COND))
			
			nLinPC := oReport:Row()
			oReport:PrintText( STR0011+SubStr(SE4->E4_COND,1,40),nLinPC,050 )
			oReport:PrintText( STR0070,nLinPC,1120 ) //"Data de Emissao"
			oReport:PrintText( STR0013 +" "+ Transform(xMoeda(nTotal,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) , tm(nTotal,14,MsDecimais(MV_PAR12)) ),nLinPC,1612 ) //"Total das Mercadorias : "
			oReport:SkipLine()
			nLinPC := oReport:Row()
			
			If cPaisLoc<>"BRA"
				aValIVA := MaFisRet(,"NF_VALIMP")
				nValIVA :=0
				If !Empty(aValIVA)
					For nY:=1 to Len(aValIVA)
						nValIVA+=aValIVA[nY]
					Next nY
				EndIf
				oReport:PrintText(SubStr(SE4->E4_DESCRI,1,34),nLinPC, 050 )
				oReport:PrintText( dtoc(SC7->C7_EMISSAO),nLinPC,1120 )
				oReport:PrintText( STR0063+ "   " + ; //"Total dos Impostos:    "
				Transform(xMoeda(nValIVA,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) , tm(nValIVA,14,MsDecimais(MV_PAR12)) ),nLinPC,1612 )
			Else
				oReport:PrintText( SubStr(SE4->E4_DESCRI,1,34),nLinPC, 050 )
				oReport:PrintText( dtoc(SC7->C7_EMISSAO),nLinPC,1120 )
				oReport:PrintText( STR0064+ "  " + ; //"Total com Impostos:    "
				Transform(xMoeda(nTotMerc,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) , tm(nTotMerc,14,MsDecimais(MV_PAR12)) ),nLinPC,1612 )
			Endif
			oReport:SkipLine()
			
			nTotIpi	  := MaFisRet(,'NF_VALIPI')
			nTotIcms  := MaFisRet(,'NF_VALICM')
			nTotDesp  := MaFisRet(,'NF_DESPESA')
			nTotFrete := MaFisRet(,'NF_FRETE')
			nTotSeguro:= MaFisRet(,'NF_SEGURO')
			nTotalNF  := MaFisRet(,'NF_TOTAL')
			
			oReport:SkipLine()
			oReport:SkipLine()
			nLinPC := oReport:Row()
			
			SM4->(dbSetOrder(1))
			If SM4->(dbSeek(xFilial("SM4")+SC7->C7_REAJUST))
				oReport:PrintText(  STR0014 + " " + SC7->C7_REAJUST + " " + SM4->M4_DESCR ,nLinPC, 050 )  //"Reajuste :"
			EndIf			

			If cPaisLoc == "BRA"
				oReport:PrintText( STR0071 + Transform(xMoeda(nTotIPI ,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) , tm(nTotIpi ,14,MsDecimais(MV_PAR12))) ,nLinPC,1320 ) //"IPI      :"
				oReport:PrintText( STR0072 + Transform(xMoeda(nTotIcms,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) , tm(nTotIcms,14,MsDecimais(MV_PAR12))) ,nLinPC,1815 ) //"ICMS     :"
			EndIf
			oReport:SkipLine()

			nLinPC := oReport:Row()
			oReport:PrintText( STR0073 + Transform(xMoeda(nTotFrete,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) , tm(nTotFrete,14,MsDecimais(MV_PAR12))) ,nLinPC,1320 ) //"Frete    :"
			oReport:PrintText( STR0074 + Transform(xMoeda(nTotDesp ,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) , tm(nTotDesp ,14,MsDecimais(MV_PAR12))) ,nLinPC,1815 ) //"Despesas :"
			oReport:SkipLine()
			
			// Inicializar campos de Observacoes.                           
			
			If Empty(cObs02)
				If Len(cObs01) > 50
					cObs := cObs01
					cObs01 := Substr(cObs,1,50)
					For nX := 2 To 4
						cVar  := "cObs"+StrZero(nX,2)
						&cVar := Substr(cObs,(50*(nX-1))+1,50)
					Next
				EndIf
			Else                	
				cObs01:= Substr(cObs01,1,IIf(Len(cObs01)<50,Len(cObs01),50))
				cObs02:= Substr(cObs02,1,IIf(Len(cObs02)<50,Len(cObs01),50))
				cObs03:= Substr(cObs03,1,IIf(Len(cObs03)<50,Len(cObs01),50))
				cObs04:= Substr(cObs04,1,IIf(Len(cObs04)<50,Len(cObs01),50))
			EndIf
			
			cComprador:= ""
			cAlter	  := ""
			cAprov	  := ""   
			cSolic    := ""		
			lNewAlc	  := .F.
			lLiber 	  := .F.
			
			dbSelectArea("SC7")
			If !Empty(SC7->C7_APROV)
				
				cTipoSC7:= IIF(SC7->C7_TIPO == 1,"PC","AE")
				lNewAlc := .T.
				cComprador := UsrFullName(SC7->C7_USER)  
				If SC7->C7_CONAPRO != "B"
					lLiber := .T.
				EndIf                                        
				// inicio da rotina que captura o nome do solicitante
				if !empty(SC7->C7_NUMSC)
				dbSelectArea("SC1")
				dbSetOrder(1)  // Nº SOLICITAÇÃO
				dbSeek(xFilial("SC1")+SC7->C7_NUMSC)			 
				IF !FOUND()
					cSolic := " "
					ELSE    
					cSolic := SUBSTR(SC1->C1_SOLICIT,1,30)
					ENDIF   
				ENDIF   
				// final da rotina 			   
				dbSelectArea("SCR")
				dbSetOrder(1)
				dbSeek(xFilial("SCR")+cTipoSC7+SC7->C7_NUM)
				While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM) == xFilial("SCR")+Alltrim(SC7->C7_NUM) .And. SCR->CR_TIPO == cTipoSC7
					cAprov += AllTrim(UsrFullName(SCR->CR_USER))+" ["
					Do Case
						Case SCR->CR_STATUS=="03" //Liberado
							cAprov += "Ok"
						Case SCR->CR_STATUS=="04" //Bloqueado
							cAprov += "BLQ"
						Case SCR->CR_STATUS=="05" //Nivel Liberado
							cAprov += "##"
						OtherWise                 //Aguar.Lib
							cAprov += "??"
					EndCase
					cAprov += "] - "
					dbSelectArea("SCR")
					dbSkip()
				Enddo
				If !Empty(SC7->C7_GRUPCOM)
					dbSelectArea("SAJ")
					dbSetOrder(1)
					dbSeek(xFilial("SAJ")+SC7->C7_GRUPCOM)
					While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+SC7->C7_GRUPCOM
						If SAJ->AJ_USER != SC7->C7_USER
							cAlter += AllTrim(UsrFullName(SAJ->AJ_USER))+"/"
						EndIf
						dbSelectArea("SAJ")
						dbSkip()
					EndDo
				EndIf
			EndIf

			nLinPC := oReport:Row()
			oReport:PrintText( STR0077 ,nLinPC, 050 ) // "Observacoes "
			oReport:PrintText( STR0076 + Transform(xMoeda(nTotSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) , tm(nTotSeguro,14,MsDecimais(MV_PAR12))) ,nLinPC, 1815 ) // "SEGURO   :"
			oReport:SkipLine()

			oReport:PrintText(cObs01,,050 )
			oReport:PrintText(cObs02,,050 )

			nLinPC := oReport:Row()
			oReport:PrintText(cObs03,nLinPC,050 )

			If !lNewAlc
				oReport:PrintText( STR0078 + Transform(xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) , tm(nTotalNF,14,MsDecimais(MV_PAR12))) ,nLinPC,1774 ) //"Total Geral :"
			Else
				If lLiber
					oReport:PrintText( STR0078 + Transform(xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) , tm(nTotalNF,14,MsDecimais(MV_PAR12))) ,nLinPC,1774 )
				Else
					oReport:PrintText( STR0078 + If(SC7->C7_TIPO == 1,STR0051,STR0086) ,nLinPC,1390 )
				EndIf
			EndIf
			oReport:SkipLine()
			
			oReport:PrintText(cObs04,,050 )
			
			If !lNewAlc
				
				oReport:Box( 2700 , 0010 , 3020 , 0400 )
				oReport:Box( 2700 , 0400 , 3020 , 0800 )
				oReport:Box( 2700 , 0800 , 3020 , 1220 )
				oReport:Box( 2600 , 1220 , 3020 , 1770 )
				oReport:Box( 2600 , 1770 , 3020 , nPageWidth )
				
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()

				nLinPC := oReport:Row()
				oReport:PrintText( If(SC7->C7_TIPO == 1,STR0079,STR0084),nLinPC,1310) //"Liberacao do Pedido"##"Liber. Autorizacao "
				oReport:PrintText( STR0080 + IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF"," " )) ,nLinPC,1820 )
				oReport:SkipLine()

				oReport:SkipLine()
				oReport:SkipLine()

				nLinPC := oReport:Row()
				oReport:PrintText( STR0021 ,nLinPC, 050 ) //"Comprador"
				oReport:PrintText( STR0022 ,nLinPC, 430 ) //"Gerencia"
				oReport:PrintText( STR0023 ,nLinPC, 850 ) //"Diretoria"			
				oReport:SkipLine()

				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()

				nLinPC := oReport:Row()
				oReport:PrintText( Replic("_",23) ,nLinPC,  050 )
				oReport:PrintText( Replic("_",23) ,nLinPC,  430 )
				oReport:PrintText( Replic("_",23) ,nLinPC,  850 )
				oReport:PrintText( Replic("_",31) ,nLinPC, 1310 )
				oReport:SkipLine()

				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()
				If SC7->C7_TIPO == 1
					oReport:PrintText(STR0081,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
				Else
					oReport:PrintText(STR0083,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
				EndIf
				
			Else
				
				oReport:Box( 2570 , 1220 , 2700 , 1850 )
				oReport:Box( 2570 , 1850 , 2700 , nPageWidth )
				oReport:Box( 2700 , 0010 , 3020 , nPageWidth )
				oReport:Box( 2970 , 0010 , 3020 , 1340 )
				
				oReport:SkipLine()
				oReport:SkipLine()

				nLinPC := oReport:Row()
				oReport:PrintText( If(SC7->C7_TIPO == 1, If( lLiber , STR0050 , STR0051 ) , If( lLiber , STR0085 , STR0086 ) ),nLinPC,1290 ) //"     P E D I D O   L I B E R A D O"#"|     P E D I D O   B L O Q U E A D O !!!"
				oReport:PrintText( STR0080 + If( SC7->C7_TPFRETE $ "F","FOB",If(SC7->C7_TPFRETE $ "C","CIF"," " )),nLinPC,1920 ) //"Obs. do Frete: "
				oReport:SkipLine()

				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:PrintText(STR0052+" "+Substr(cComprador,1,60),,050 ) 	//"Comprador Responsavel :" //"BLQ:Bloqueado"
				oReport:SkipLine()
				oReport:PrintText(STR0053+" "+If( Len(cAlter) > 0 , Substr(cAlter,001,130) , " " ),,050 ) //"Compradores Alternativos :"
				oReport:PrintText(            If( Len(cAlter) > 0 , Substr(cAlter,131,130) , " " ),,440 ) //"Compradores Alternativos :"
				oReport:SkipLine()
				oReport:PrintText(STR0054+" "+If( Len(cAprov) > 0 , Substr(cAprov,001,140) , " " ),,050 ) //"Aprovador(es) :"
				oReport:PrintText(            If( Len(cAprov) > 0 , Substr(cAprov,141,140) , " " ),,310 ) //"Aprovador(es) :"
				oReport:SkipLine() 
				nLinPC := oReport:Row()
				oReport:PrintText( STR0082+" "+STR0060 ,nLinPC, 050 ) 	//"Legendas da Aprovacao : //"BLQ:Bloqueado"
				oReport:PrintText(       "|  "+STR0061 ,nLinPC, 610 ) 	//"Ok:Liberado"
				oReport:PrintText(       "|  "+STR0062 ,nLinPC, 830 ) 	//"??:Aguar.Lib"
				oReport:PrintText(       "|  "+STR0067 ,nLinPC,1070 )	//"##:Nivel Lib"
				oReport:SkipLine()

				oReport:SkipLine()
				If SC7->C7_TIPO == 1
					oReport:PrintText(STR0081,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
				Else
					oReport:PrintText(STR0083,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
				EndIf
			EndIf

		Next nVias
		
		MaFisEnd()
		
		// Grava no SC7 as Reemissoes e atualiza o Flag de impressao.   
		
		dbSelectArea("SC7")
		If Len(aRecnoSave) > 0
			For nX :=1 to Len(aRecnoSave)
				dbGoto(aRecnoSave[nX])
				RecLock("SC7",.F.)
				SC7->C7_QTDREEM := (SC7->C7_QTDREEM + 1)
				SC7->C7_EMITIDO := "S"
				MsUnLock()
			Next nX
			
			// Reposiciona o SC7 com base no ultimo elemento do aRecnoSave. 
			
			dbGoto(aRecnoSave[Len(aRecnoSave)])
		Endif
		
		Aadd(aPedMail,aPedido)
		
		aRecnoSave := {}
		
		dbSelectArea("SC7")
		dbSkip()
		
	EndDo

	oSection2:Finish()

	// Executa o ponto de entrada M110MAIL quando a impressao for   
	// enviada por email, fornecendo um Array para o usuario conten 
	// do os pedidos enviados para possivel manipulacao.            

	If ExistBlock("M110MAIL")
		lEnvMail := HasEmail(,,,,.F.)
		If lEnvMail
			Execblock("M110MAIL",.F.,.F.,{aPedMail})
		EndIf
	EndIf

	If lAuto .And. !lImpri
		Aviso(STR0104,STR0105,{"OK"})
	Endif

	dbSelectArea("SC7")
	dbClearFilter()
	dbSetOrder(1)

Return

Static Function CabecPCxAE(oReport,oSection1,nVias,nPagina)

	Local cMoeda := IIf( mv_par12 < 10 , Str(mv_par12,1) , Str(mv_par12,2) )
	Local nLinPC := 0
	Local nPageWidth:= 2290
	TRPosition():New(oSection1,"SA2",1,{ || xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA })

	SA2->(dbSetOrder(1))
	SA2->(dbSeek(xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA))

	oSection1:Init()

	oReport:Box( 010 , 010 ,  260 , 0790 )
	oReport:Box( 010 , 800 ,  260 , nPageWidth-2 ) // 2288

	oReport:PrintText( If(nPagina > 1,(STR0033)," "),,oSection1:Cell("M0_NOMECOM"):ColPos())

	nLinPC := oReport:Row()
	oReport:PrintText( If( mv_par08 == 1 , (STR0068), (STR0069) ) + " - " + GetMV("MV_MOEDA"+cMoeda) ,nLinPC,820 )
	oReport:PrintText( If( mv_par08 == 1 , SC7->C7_NUM, SC7->C7_NUMSC + "/" + SC7->C7_NUM ) + " /" + Ltrim(Str(nPagina,2)) ,nLinPC,1700 )
	oReport:PrintText( If( SC7->C7_QTDREEM > 0, Str(SC7->C7_QTDREEM+1,2) , "1" ) + STR0034 + Str(nVias,2) + STR0035 ,nLinPC,1960 )
	oReport:SkipLine()

	oReport:SkipLine()
	nLinPC := oReport:Row()
	oReport:PrintText(STR0087 + SM0->M0_NOMECOM,nLinPC,15)  // "Empresa:"
	oReport:PrintText(STR0106 + SA2->A2_NOME+" "+STR0107+SA2->A2_COD+" "+STR0108+SA2->A2_LOJA,nLinPC,815)
	oReport:SkipLine()

	nLinPC := oReport:Row()
	oReport:PrintText(STR0088 + SM0->M0_ENDENT,nLinPC,15)
	oReport:PrintText(STR0088 + SA2->A2_END+" "+STR0109+SA2->A2_BAIRRO,nLinPC,815)
	oReport:SkipLine()
								
	nLinPC := oReport:Row()
	oReport:PrintText(STR0089 + Trans(SM0->M0_CEPENT,PesqPict("SA2","A2_CEP"))+Space(2)+STR0090 + SM0->M0_CIDENT + STR0091 + SM0->M0_ESTENT ,nLinPC,15)
	oReport:PrintText(STR0110+SA2->A2_MUN+" "+STR0111+SA2->A2_EST+" "+STR0112+SA2->A2_CEP+" "+STR0113+Transform(SA2->A2_CGC,PesqPict("SA2","A2_CGC")),nLinPC,815)
	oReport:SkipLine()

	nLinPC := oReport:Row()
	oReport:PrintText(STR0092 + SM0->M0_TEL + Space(2) + STR0093 + SM0->M0_FAX ,nLinPC,15)
	oReport:PrintText(STR0094 + "("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15) + " "+STR0114+"("+Substr(SA2->A2_DDD,1,3)+") "+SubStr(SA2->A2_FAX,1,15)+" "+If( cPaisLoc$"ARG|POR|EUA",space(11) , STR0095 )+If( cPaisLoc$"ARG|POR|EUA",space(18), SA2->A2_INSCR ),nLinPC,815)
	oReport:SkipLine()

	nLinPC := oReport:Row()
	oReport:PrintText(STR0096 + Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC")) ,nLinPC,15)
	If cPaisLoc == "BRA"
		oReport:PrintText(STR0041 + InscrEst() ,nLinPC,415)
	Endif
	oReport:SkipLine()
	oReport:SkipLine()

	oSection1:Finish()

Return

USER Function AD110R3(cAlias,nReg,nOpcx)

	LOCAL wnrel		:= "ADMTR110"
	LOCAL cDesc1	:= "Emissao dos pedidos de compras (via cega) "
	LOCAL cDesc2	:= STR0002	//"cadastradados e que ainda nao foram impressos"
	LOCAL cDesc3	:= " "
	LOCAL cString	:= "SC7"
	Local lComp		:= .T.	// Ativado habilita escolher modo RETRATO / PAISAGEM
	Local cUserId   := RetCodUsr()
	Local cCont     := Nil

	PRIVATE lAuto		:= (nReg!=Nil)
	PRIVATE Tamanho		:= "G"
	PRIVATE titulo	 	:="Emissao dos Pedidos de Compras (via cega)"
	PRIVATE aReturn 	:= {STR0004, 1,STR0005, 1, 2, 1, "",0 }		//"Zebrado"###"Administracao"
	PRIVATE nomeprog	:="ADMTR110"
	PRIVATE nLastKey	:= 0
	PRIVATE nBegin		:= 0
	PRIVATE nDifColCC   := 0
	PRIVATE aLinha		:= {}
	PRIVATE aSenhas		:= {}
	PRIVATE aUsuarios	:= {}
	PRIVATE M_PAG		:= 1
	PRIVATE cPerg := PADR("MTR110",10," ")
	If Type("lPedido") != "L"
		lPedido := .F.
	Endif

	U_ADINF009P('ADMTR110' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Pedido de Compras / Autorizacao de Entrega Especifico Adoro para atender solicitacao Rosangela')

	// Variaveis utilizadas para parametros                         
	// mv_par01               Do Pedido                             
	// mv_par02               Ate o Pedido                          
	// mv_par03               A partir da data de emissao           
	// mv_par04               Ate a data de emissao                 
	// mv_par05               Somente os Novos                      
	// mv_par06               Campo Descricao do Produto    	    
	// mv_par07               Unidade de Medida:Primaria ou Secund. 
	// mv_par08               Imprime ? Pedido Compra ou Aut. Entreg
	// mv_par09               Numero de vias                        
	// mv_par10               Pedidos ? Liberados Bloqueados Ambos  
	// mv_par11               Impr. SC's Firmes, Previstas ou Ambas 
	// mv_par12               Qual a Moeda ?                        
	// mv_par13               Endereco de Entrega                   
	// mv_par14               todas ou em aberto ou atendidos       

	AjustaSX1()
	Pergunte(cPerg,.F.)

	// Verifica se no SX3 o C7_CC esta com tamanho 9 (Default) se igual a 9 muda o tamanho do relatorio           
	// para Medio possibilitando a impressao em modo Paisagem ou retrato atraves da reducao na variavel nDifColCC 
	// se o tamanho do C7_CC no SX3 estiver > que 9 o relatorio sera impresso comprrimido com espaco para o campo 
	// C7_CC centro de custo para ate 20 posicoes,Obs.desabilitando a selecao do modo de impresso retrato/paisagem

	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek("C7_CC")
		If SX3->X3_TAMANHO == 9
			nDifColCC := 11
			Tamanho   := "M"
		Else
			lComp	  := .F.   // C.Custo c/ tamanho maior que 9, sempre PAISAGEM
		Endif
	Endif

	wnrel:=SetPrint(cString,wnrel,If(lAuto,Nil,"MTR110"),@Titulo,cDesc1,cDesc2,cDesc3,.F.,,lComp,Tamanho,,!lAuto)

	If nLastKey <> 27

		SetDefault(aReturn,cString)

		If lAuto
			mv_par08 := Eval({|| cCont:=ChkPerg110(cUserId,"MTR110","08"),If(cCont == Nil,SC7->C7_TIPO,cCont) })
		EndIf
		
		If lPedido
			mv_par12 := MAX(SC7->C7_MOEDA,1)
		Endif
		
		If mv_par08 == 1
			RptStatus({|lEnd| C110PC(@lEnd,wnRel,cString,nReg)},titulo)
		Else
			RptStatus({|lEnd| C110AE(@lEnd,wnRel,cString,nReg)},titulo)
		EndIf

		lPedido := .F.
		
	Else 
		dbClearFilter()
	EndIf

Return .T.

Static Function C110PC(lEnd,WnRel,cString,nReg)

	Local nReem
	Local nOrder
	Local cCondBus
	Local nSavRec
	Local aPedido := {}
	Local aPedMail:= {}
	Local aSavRec := {}
	Local nLinObs := 0
	Local i       := 0
	Local ncw     := 0
	Local cFiltro := ""
	Local cUserId := RetCodUsr()
	Local cCont   := Nil
	Local lImpri  := .F.

	Private cCGCPict, cCepPict

	//Definir as pictures                                           

	cCepPict:=PesqPict("SA2","A2_CEP")
	cCGCPict:=PesqPict("SA2","A2_CGC")

	If nDifColCC < 11
		limite   := 139
	Else
		limite   := 129
	Endif

	li       := 80
	nDescProd:= 0
	nTotal   := 0
	nTotMerc := 0
	NumPed   := Space(6)

	If lAuto
		dbSelectArea("SC7")
		dbGoto(nReg)
		SetRegua(1)
		mv_par01 := C7_NUM
		mv_par02 := C7_NUM
		mv_par03 := C7_EMISSAO
		mv_par04 := C7_EMISSAO
		mv_par05 := Eval({|| cCont:=ChkPerg110(cUserId,cPerg,"05"),If(cCont == Nil,2,cCont) })
		mv_par08 := Eval({|| cCont:=ChkPerg110(cUserId,cPerg,"08"),If(cCont == Nil,C7_TIPO,cCont) })
		mv_par09 := Eval({|| cCont:=ChkPerg110(cUserId,cPerg,"09"),If(cCont == Nil,1,cCont) })
		mv_par10 := Eval({|| cCont:=ChkPerg110(cUserId,cPerg,"10"),If(cCont == Nil,3,cCont) }) 
		mv_par11 := Eval({|| cCont:=ChkPerg110(cUserId,cPerg,"11"),If(cCont == Nil,3,cCont) }) 
		mv_par14 := Eval({|| cCont:=ChkPerg110(cUserId,cPerg,"14"),If(cCont == Nil,1,cCont) }) 
	EndIf

	If ( cPaisLoc$"ARG|POR|EUA" )
		cCondBus	:=	"1"+strzero(val(mv_par01),6)
		nOrder	:=	10
		nTipo		:= 1
	Else
		cCondBus	:=mv_par01
		nOrder	:=	1
	EndIf

	If mv_par14 == 2
		cFiltro := "SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)"
	Elseif mv_par14 == 3
		cFiltro := "SC7->C7_QUANT > SC7->C7_QUJE"
	EndIf

	dbSelectArea("SC7")
	dbSetOrder(nOrder)
	SetRegua(RecCount())
	dbSeek(xFilial("SC7")+cCondBus,.T.)

	// Faz manualmente porque nao chama a funcao Cabec()                 

	@ 0,0 PSay AvalImp(Iif(nDifColCC < 11,220,132))

	While !Eof() .And. C7_FILIAL = xFilial("SC7") .And. C7_NUM >= mv_par01 .And. ;
			C7_NUM <= mv_par02

		// Cria as variaveis para armazenar os valores do pedido        
		
		nOrdem   := 1
		nReem    := 0
		cObs01   := " "
		cObs02   := " "
		cObs03   := " "
		cObs04   := " "

		If	C7_EMITIDO == "S" .And. mv_par05 == 1
			dbSkip()
			Loop
		Endif
		If	(C7_CONAPRO == "B" .And. mv_par10 == 1) .Or.;
			(C7_CONAPRO != "B" .And. mv_par10 == 2)
			dbSkip()
			Loop
		Endif
		If	(C7_EMISSAO < mv_par03) .Or. (C7_EMISSAO > mv_par04)
			dbSkip()
			Loop
		Endif
		If	C7_TIPO == 2
			dbSkip()
			Loop
		EndIf

		// Consiste este item. EM ABERTO                                
		
		If mv_par14 == 2
			If SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)
				dbSelectArea("SC7")
				dbSkip()
				Loop
			Endif
		Endif

		// Consiste este item. ATENDIDOS                                
		
		If mv_par14 == 3
			If SC7->C7_QUANT > SC7->C7_QUJE
				dbSelectArea("SC7")
				dbSkip()
				Loop
			Endif
		Endif

		// Filtra Tipo de SCs Firmes ou Previstas                       
		
		If !MtrAValOP(mv_par11, 'SC7')
			dbSkip()
			Loop
		EndIf

		MaFisEnd()
		R110FIniPC(SC7->C7_NUM,,,cFiltro)
		//MaFisIniPC(SC7->C7_NUM,,,cFiltro)

		For ncw := 1 To mv_par09		// Imprime o numero de vias informadas

			ImpCabec(ncw)

			nTotal   := 0
			nTotMerc	:= 0
			nDescProd:= 0
			nReem    := SC7->C7_QTDREEM + 1
			nSavRec  := SC7->(Recno())
			NumPed   := SC7->C7_NUM
			nLinObs  := 0
			aPedido  := {SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_EMISSAO,SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_TIPO}

			While !Eof() .And. C7_FILIAL = xFilial("SC7") .And. C7_NUM == NumPed

				// Consiste este item. EM ABERTO                                
				
				If mv_par14 == 2
					If SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)
						dbSelectArea("SC7")
						dbSkip()
						Loop
					Endif
				Endif

				// Consiste este item. ATENDIDOS                                
				
				If mv_par14 == 3
					If SC7->C7_QUANT > SC7->C7_QUJE
						dbSelectArea("SC7")
						dbSkip()
						Loop
					Endif
				Endif

				If Ascan(aSavRec,Recno()) == 0		// Guardo recno p/gravacao
					AADD(aSavRec,Recno())
				Endif
				If lEnd
					@PROW()+1,001 PSAY STR0006	//"CANCELADO PELO OPERADOR"
					Goto Bottom
					Exit
				Endif

				IncRegua()

				// Verifica se havera salto de formulario                       
				
				If li > 56
					nOrdem++
					ImpRodape()			// Imprime rodape do formulario e salta para a proxima folha
					ImpCabec(ncw)
				Endif

				li++

				@ li,001 PSAY "|"
				@ li,002 PSAY C7_ITEM  		Picture PesqPict("SC7","c7_item")
				@ li,006 PSAY "|"
				@ li,007 PSAY C7_PRODUTO	Picture PesqPict("SC7","c7_produto")
				
				// Pesquisa Descricao do Produto                                
				
				ImpProd()

				If SC7->C7_DESC1 != 0 .or. SC7->C7_DESC2 != 0 .or. SC7->C7_DESC3 != 0
					nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
				Else
					nDescProd+=SC7->C7_VLDESC
				Endif
				
				// Inicializacao da Observacao do Pedido.                       
				
				If !EMPTY(SC7->C7_OBS) .And. nLinObs < 5
					nLinObs++
					cVar:="cObs"+StrZero(nLinObs,2)
					Eval(MemVarBlock(cVar),SC7->C7_OBS)
				Endif
				lImpri  := .T.
				dbSkip()
			EndDo

			dbGoto(nSavRec)

			If li>38
				nOrdem++
				ImpRodape()		// Imprime rodape do formulario e salta para a proxima folha
				ImpCabec(ncw)
			Endif

			FinalPed(nDescProd)		// Imprime os dados complementares do PC

		Next

		MaFisEnd()

		If Len(aSavRec)>0
			For i:=1 to Len(aSavRec)
				dbGoto(aSavRec[i])
				RecLock("SC7",.F.)  //Atualizacao do flag de Impressao
				Replace C7_QTDREEM With (C7_QTDREEM+1)
				Replace C7_EMITIDO With "S"
				MsUnLock()
			Next
			dbGoto(aSavRec[Len(aSavRec)])		// Posiciona no ultimo elemento e limpa array
		Endif

		Aadd(aPedMail,aPedido)

		aSavRec := {}

		dbSkip()
	EndDo

	// Executa o ponto de entrada M110MAIL quando a impressao for   
	// enviada por email, fornecendo um Array para o usuario conten 
	// do os pedidos enviados para possivel manipulacao.            

	If ExistBlock("M110MAIL")
		lEnvMail := HasEmail(,,,,.F.)
		If lEnvMail
			Execblock("M110MAIL",.F.,.F.,{aPedMail})
		EndIf
	EndIf

	If lAuto .And. !lImpri
		Aviso(STR0104,STR0105,{"OK"})
	Endif

	dbSelectArea("SC7")
	dbClearFilter()
	dbSetOrder(1)

	dbSelectArea("SX3")
	dbSetOrder(1)

	// Se em disco, desvia para Spool                               

	If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer TO
		dbCommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()

Return .T.

Static Function C110AE(lEnd,WnRel,cString,nReg)

	Local nReem
	Local nSavRec,aSavRec := {}
	Local aPedido := {}
	Local aPedMail:= {}
	Local nLinObs := 0
	Local ncw     := 0
	Local i       := 0
	Local cFiltro := ""
	Local cUserId := RetCodUsr()
	Local lImpri  := .F.

	Private cCGCPict, cCepPict

	//Definir as pictures                                           

	cCepPict:=PesqPict("SA2","A2_CEP")
	cCGCPict:=PesqPict("SA2","A2_CGC")

	If nDifColCC < 11
		limite   := 139
	Else
		limite   := 129
	Endif

	li       := 80
	nDescProd:= 0
	nTotal   := 0
	nTotMerc := 0
	NumPed   := Space(6)

	If !lAuto
		dbSelectArea("SC7")
		dbSetOrder(10)
		dbSeek(xFilial("SC7")+"2"+mv_par01,.T.)
	Else
		dbSelectArea("SC7")
		dbGoto(nReg)
		mv_par01 := C7_NUM
		mv_par02 := C7_NUM
		mv_par03 := C7_EMISSAO
		mv_par04 := C7_EMISSAO
		mv_par05 := Eval({|| cCont:=ChkPerg110(cUserId,cPerg,"05"),If(cCont == Nil,2,cCont) })
		mv_par08 := Eval({|| cCont:=ChkPerg110(cUserId,cPerg,"08"),If(cCont == Nil,C7_TIPO,cCont) })
		mv_par09 := Eval({|| cCont:=ChkPerg110(cUserId,cPerg,"09"),If(cCont == Nil,1,cCont) })
		mv_par10 := Eval({|| cCont:=ChkPerg110(cUserId,cPerg,"10"),If(cCont == Nil,3,cCont) }) 
		mv_par11 := Eval({|| cCont:=ChkPerg110(cUserId,cPerg,"11"),If(cCont == Nil,3,cCont) }) 
		mv_par14 := Eval({|| cCont:=ChkPerg110(cUserId,cPerg,"14"),If(cCont == Nil,1,cCont) }) 

		dbSelectArea("SC7")
		dbSetOrder(10)
		dbSeek(xFilial("SC7")+"2"+mv_par01,.T.)
	EndIf

	If mv_par14 == 2
		cFiltro := "SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)"
	Elseif mv_par14 == 3
		cFiltro := "SC7->C7_QUANT > SC7->C7_QUJE"
	EndIf

	SetRegua(Reccount())

	// Faz manualmente porque nao chama a funcao Cabec()                 

	@ 0,0 PSay AvalImp(Iif(nDifColCC < 11,220,132))
	While !Eof().And.C7_FILIAL = xFilial("SC7") .And. C7_NUM >= mv_par01 .And. C7_NUM <= mv_par02
		
		// Cria as variaveis para armazenar os valores do pedido        
		
		nOrdem   := 1
		nReem    := 0
		cObs01   := " "
		cObs02   := " "
		cObs03   := " "
		cObs04   := " "

		If	C7_EMITIDO == "S" .And. mv_par05 == 1
			dbSelectArea("SC7")
			dbSkip()
			Loop
		Endif
		If	(C7_CONAPRO == "B" .And. mv_par10 == 1) .Or.;
			(C7_CONAPRO != "B" .And. mv_par10 == 2)
			dbSelectArea("SC7")
			dbSkip()
			Loop
		Endif
		If	(SC7->C7_EMISSAO < mv_par03) .Or. (SC7->C7_EMISSAO > mv_par04)
			dbSelectArea("SC7")
			dbSkip()
			Loop
		Endif
		If	SC7->C7_TIPO != 2
			dbSelectArea("SC7")
			dbSkip()
			Loop
		EndIf

		// Consiste este item. EM ABERTO                                
		
		If mv_par14 == 2
			If SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)
				dbSelectArea("SC7")
				dbSkip()
				Loop
			Endif
		Endif
		
		// Consiste este item. ATENDIDOS                                
		
		If mv_par14 == 3
			If SC7->C7_QUANT > SC7->C7_QUJE
				dbSelectArea("SC7")
				dbSkip()
				Loop
			Endif
		Endif

		// Filtra Tipo de SCs Firmes ou Previstas                       
		
		If !MtrAValOP(mv_par11, 'SC7')
			dbSelectArea("SC7")
			dbSkip()
			Loop
		EndIf

		MaFisEnd()
		R110FIniPC(SC7->C7_NUM,,,cFiltro)
		//MaFisIniPC(SC7->C7_NUM,,,cFiltro)

		For ncw := 1 To mv_par09		// Imprime o numero de vias informadas

			ImpCabec(ncw)

			nTotal   := 0
			nTotMerc := 0

			nDescProd:= 0
			nReem    := SC7->C7_QTDREEM + 1
			nSavRec  := SC7->(Recno())
			NumPed   := SC7->C7_NUM
			nLinObs := 0
			aPedido  := {SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_EMISSAO,SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_TIPO}

			While !Eof() .And. C7_FILIAL = xFilial("SC7") .And. C7_NUM == NumPed

				// Consiste este item. EM ABERTO                                
				
				If mv_par14 == 2
					If SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)
						dbSelectArea("SC7")
						dbSkip()
						Loop
					Endif
				Endif
				
				// Consiste este item. ATENDIDOS                                
				
				If mv_par14 == 3
					If SC7->C7_QUANT > SC7->C7_QUJE
						dbSelectArea("SC7")
						dbSkip()
						Loop
					Endif
				Endif

				If Ascan(aSavRec,Recno()) == 0		// Guardo recno p/gravacao
					AADD(aSavRec,Recno())
				Endif

				If lEnd
					@PROW()+1,001 PSAY STR0006		//"CANCELADO PELO OPERADOR"
					Goto Bottom
					Exit
				Endif

				IncRegua()

				// Verifica se havera salto de formulario                       
				
				If li > 56
					nOrdem++
					ImpRodape()		// Imprime rodape do formulario e salta para a proxima folha
					ImpCabec(ncw)
				Endif
				li++
				@ li,001 PSAY "|"
				@ li,002 PSAY SC7->C7_ITEM  	Picture PesqPict("SC7","C7_ITEM")
				@ li,006 PSAY "|"
				@ li,007 PSAY SC7->C7_PRODUTO	Picture PesqPict("SC7","C7_PRODUTO")
				
				// Pesquisa Descricao do Produto                                
				
				ImpProd()		// Imprime dados do Produto

				If SC7->C7_DESC1 != 0 .or. SC7->C7_DESC2 != 0 .or. SC7->C7_DESC3 != 0
					nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
				Else
					nDescProd+=SC7->C7_VLDESC
				Endif
				
				// Inicializacao da Observacao do Pedido.                       
				
				If !EMPTY(SC7->C7_OBS) .And. nLinObs < 5
					nLinObs++
					cVar:="cObs"+StrZero(nLinObs,2)
					Eval(MemVarBlock(cVar),SC7->C7_OBS)
				Endif
				lImpri  := .T.
				dbSelectArea("SC7")
				dbSkip()
			EndDo

			dbGoto(nSavRec)
			If li>38
				nOrdem++
				ImpRodape()		// Imprime rodape do formulario e salta para a proxima folha
				ImpCabec(ncw)
			Endif

			FinalAE(nDescProd)		// dados complementares da Autorizacao de Entrega
		Next

		MaFisEnd()

		If Len(aSavRec)>0
			dbGoto(aSavRec[Len(aSavRec)])
			For i:=1 to Len(aSavRec)
				dbGoto(aSavRec[i])
				RecLock("SC7",.F.)  //Atualizacao do flag de Impressao
				Replace C7_EMITIDO With "S"
				Replace C7_QTDREEM With (C7_QTDREEM+1)
				MsUnLock()
			Next
		Endif

		Aadd(aPedMail,aPedido)

		aSavRec := {}

		dbSelectArea("SC7")
		dbSkip()
	End

	// Executa o ponto de entrada M110MAIL quando a impressao for   
	// enviada por email, fornecendo um Array para o usuario conten 
	// do os pedidos enviados para possivel manipulacao.            

	If ExistBlock("M110MAIL")
		lEnvMail := HasEmail(,,,,.F.)
		If lEnvMail
			Execblock("M110MAIL",.F.,.F.,{aPedMail})
		EndIf
	EndIf

	If lAuto .And. !lImpri
		Aviso(STR0104,STR0105,{"OK"})
	Endif

	dbSelectArea("SC7")
	dbClearFilter()
	dbSetOrder(1)

	dbSelectArea("SX3")
	dbSetOrder(1)

	// Se em disco, desvia para Spool                               

	If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer TO
		Commit
		ourspool(wnrel)
	Endif

	MS_FLUSH()

Return .T.

Static Function ImpProd()

	LOCAL nBegin := 0, cDescri := "", nLinha:=0
	Local	nTamDesc := 50, aColuna := Array(8) //Everson - 16/08/2019. Chamado 050939.

	If Empty(mv_par06)
		mv_par06 := "B1_DESC"
	EndIf

	// Impressao da descricao generica do Produto.                  

	If AllTrim(mv_par06) == "B1_DESC"
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek( xFilial("SB1")+SC7->C7_PRODUTO )
		cDescri := Alltrim(SB1->B1_DESC) + " *** " + Alltrim(SB1->B1_DESCOMP) //Everson - 16/08/2019. Chamado 050939.
		dbSelectArea("SC7")
	EndIf

	// Impressao da descricao cientifica do Produto.                

	If AllTrim(mv_par06) == "B5_CEME"
		dbSelectArea("SB5")
		dbSetOrder(1)
		If dbSeek( xFilial("SB5")+SC7->C7_PRODUTO )
			cDescri := Alltrim(B5_CEME)
		EndIf
		dbSelectArea("SC7")
	EndIf

	dbSelectArea("SC7")
	If AllTrim(mv_par06) == "C7_DESCRI"
		cDescri := Alltrim(SC7->C7_DESCRI)
	EndIf

	If Empty(cDescri)
		dbSelectArea("SB1")
		dbSetOrder(1)
		MsSeek( xFilial("SB1")+SC7->C7_PRODUTO )
		cDescri := Alltrim(SB1->B1_DESC) + " *** " + Alltrim(SB1->B1_DESCOMP) //Everson - 16/08/2019. Chamado 050939.
		dbSelectArea("SC7")
	EndIf

	dbSelectArea("SA5")
	dbSetOrder(1)
	If dbSeek(xFilial("SA5")+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_PRODUTO).And. !Empty(SA5->A5_CODPRF)
		cDescri := cDescri + " ("+Alltrim(A5_CODPRF)+")"
	EndIf

	cDescri := Alltrim(cDescri) //Everson - 16/08/2019. Chamado 050939.

	dbSelectArea("SC7")
	aColuna[1] :=  49
	aColuna[2] :=  52
	aColuna[3] :=  65
	aColuna[4] :=  80
	aColuna[5] :=  86
	aColuna[6] := 103
	aColuna[7] := 114
	acoluna[8] := 142 - nDifColCC

	nLinha:= MLCount(cDescri,nTamDesc)

	@ li,022 PSAY "|"
	@ li,023 PSAY MemoLine(cDescri,nTamDesc,1)

	ImpCampos()
	For nBegin := 2 To nLinha
		li++
		@ li,001 PSAY "|"
		@ li,006 PSAY "|"
		@ li,022 PSAY "|"
		@ li,023 PSAY Memoline(cDescri,nTamDesc,nBegin)
		
		//Everson - 16/08/2019. Chamado 050939.
		//@ li,aColuna[1] PSAY "|"
		//@ li,acoluna[2] PSAY "|"
		//@ li,acoluna[3] PSAY "|"
		@ li,aColuna[4] PSAY "|"

		If mv_par08 == 1
			If cPaisLoc == "BRA"
				@ li,aColuna[5] PSAY "|"
			Else
				@ li,aColuna[5] PSAY " "
			EndIf
			@ li,aColuna[6] PSAY "|"
			@ li,114 PSAY "|"
			@ li,135 - nDIfColCC PSAY "|"
			@ li,aColuna[8] PSAY "|"
		Else
			@ li,097 PSAY "|"
			@ li,108 PSAY "|"
			@ li,142 - nDifColCC PSAY "|"
		EndIf
		
		//Everson - 16/08/2019. Chamado 050939.
		li++
		@ li,002 PSAY Replicate("-",limite)
		
	Next nBegin

Return NIL

Static Function ImpCampos()

	LOCAL aColuna[6]
	Local nTxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
	dbSelectArea("SC7")

	aColuna[1] :=  49
	aColuna[2] :=  52
	aColuna[3] :=  65
	aColuna[4] :=  80
	aColuna[5] :=  86
	aColuna[6] := 103

	//Everson - 16/08/2019. Chamado 050939.
	//@ li,aColuna[1] PSAY "|"
	@ li,aColuna[4] PSAY "|"
	If MV_PAR07 == 2 .And. !Empty(SC7->C7_SEGUM)
		@ li,PCOL() PSAY SC7->C7_SEGUM Picture PesqPict("SC7","C7_UM")
	Else
		@ li,PCOL() PSAY SC7->C7_UM    Picture PesqPict("SC7","C7_UM")
	EndIf

	//Everson - 16/08/2019. Chamado 050939.
	/*@ li,aColuna[2] PSAY "|"
	If MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM)
	//	@ li,PCOL() PSAY SC7->C7_QTSEGUM Picture PesqPictQt("C7_QUANT",13)
	Else
	//	@ li,PCOL() PSAY SC7->C7_QUANT   Picture PesqPictQt("C7_QUANT",13)
	EndIf*/

	//Everson - 16/08/2019. Chamado 050939.
	/*@ li,aColuna[3] PSAY "|"
	If MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM)
	//	@ li,PCOL()	PSAY xMoeda((SC7->C7_TOTAL/SC7->C7_QTSEGUM),SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture PesqPict("SC7","C7_PRECO",14, mv_par12)
	Else
	//	@ li,PCOL() PSAY xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture PesqPict("SC7","C7_PRECO",14,mv_par12)
	EndIf*/

	@ li,aColuna[5] PSAY "|"

	If mv_par08 == 1

	//Everson - 16/08/2019. Chamado 050939.
	/*	If cPaisLoc == "BRA"
	//		@ li,    PCOL() PSAY SC7->C7_IPI Picture PesqPictQt("C7_IPI",5)
			@ li,    aColuna[5] PSAY "|"
		Else
			@ li,    PCOL() 	PSAY "  "
			@ li,aColuna[5]-2 	PSAY " "
			@ li,    PCOL() 	PSAY " "
		EndIf*/
		
	//	@ li,    PCOL() PSAY xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture PesqPict("SC7","C7_TOTAL",16,mv_par12)
		@ li,aColuna[6] PSAY "|"
		@ li,    PCOL() PSAY SC7->C7_DATPRF Picture PesqPict("SC7","C7_DATPRF")
		@ li,114 PSAY "|"
		@ li,PCOL() PSAY SC7->C7_CC         Picture PesqPict("SC7","C7_CC",20)
		@ li,135 - nDifColCC PSAY "|"
		@ li,  PCOL() PSAY SC7->C7_NUMSC
		@ li,142 - nDifColCC PSAY "|"
	Else
	//	@ li,  PCOL() PSAY xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture PesqPict("SC7","C7_TOTAL",16,mv_par12)
		@ li,     097 PSAY "|"
		@ li,  PCOL() PSAY SC7->C7_DATPRF   Picture PesqPict("SC7","C7_DATPRF")
		@ li,     108 PSAY "|"
		// Tenta imprimir OP
		If !Empty(SC7->C7_OP)
			@ li,  PCOL() PSAY STR0065
			@ li,  PCOL() PSAY SC7->C7_OP
		// Caso Op esteja vazia imprime Centro de Custos
		ElseIf !Empty(SC7->C7_CC)
			@ li,  PCOL() PSAY STR0066
			@ li,PCOL() PSAY SC7->C7_CC     Picture PesqPict("SC7","C7_CC",20)
		EndIf
		@ li,142 - nDifColCC PSAY "|"
	EndIf

	nTotal  :=nTotal+SC7->C7_TOTAL
	nTotMerc:=MaFisRet(,"NF_TOTAL")

Return .T.

Static Function FinalPed(nDescProd)

	Local nk		:= 1,nG
	Local nX		:= 0
	Local nQuebra	:= 0
	Local nTotDesc	:= nDescProd
	Local lNewAlc	:= .F.
	Local lLiber 	:= .F.
	Local lImpLeg	:= .T.
	Local lImpLeg2	:= .F.
	Local cComprador:=""
	LOcal cAlter	:=""
	Local cAprov	:=""   
	Local cSolic    :=""
	Local cTest     :=""
	Local nTotIpi	:= MaFisRet(,'NF_VALIPI')
	Local nTotIcms	:= MaFisRet(,'NF_VALICM')
	Local nTotDesp	:= MaFisRet(,'NF_DESPESA')
	Local nTotFrete	:= MaFisRet(,'NF_FRETE')
	Local nTotalNF	:= MaFisRet(,'NF_TOTAL')
	Local nTotSeguro:= MaFisRet(,'NF_SEGURO')
	Local aValIVA   := MaFisRet(,"NF_VALIMP")
	Local nValIVA   :=0
	Local aColuna   := Array(8), nTotLinhas
	Local nTxMoeda  := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)

	If cPaisLoc <> "BRA" .And. !Empty(aValIVA)
		For nG:=1 to Len(aValIVA)
			nValIVA+=aValIVA[nG]
		Next
	Endif

	cMensagem:= Formula(C7_MSG)

	If !Empty(cMensagem)
		li++
		@ li,001 PSAY "|"
		@ li,002 PSAY Padc(cMensagem,129)
		@ li,142 - nDifColCC PSAY "|"
	Endif
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"
	li++

	aColuna[1] :=  49
	aColuna[2] :=  52
	aColuna[3] :=  65
	aColuna[4] :=  80
	aColuna[5] :=  86
	aColuna[6] := 103
	acoluna[7] := 114
	aColuna[8] := 142 - nDifColCC
	nTotLinhas :=  39

	While li<nTotLinhas
		@ li,001 PSAY "|"
		@ li,006 PSAY "|"
		@ li,022 PSAY "|"
		@ li,022 + nk PSAY "*"
		nk := IIf( nk == 42 , 1 , nk + 1 )
		@ li,aColuna[1] PSAY "|"
		@ li,aColuna[2] PSAY "|"
		@ li,aColuna[3] PSAY "|"
		@ li,aColuna[4] PSAY "|"
		If cPaisLoc == "BRA"
			@ li,aColuna[5] PSAY "|"
		EndIf
		@ li,aColuna[6] PSAY "|"
		@ li,114 PSAY "|"
		@ li,135 - nDifColCC PSAY "|"
		@ li,aColuna[8] PSAY "|"
		li++
	EndDo
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	//@ li,015 PSAY STR0007		//"D E S C O N T O S -->"
	//@ li,037 PSAY C7_DESC1 Picture "999.99"
	//@ li,046 PSAY C7_DESC2 Picture "999.99"
	//@ li,055 PSAY C7_DESC3 Picture "999.99"

	//@ li,068 PSAY xMoeda(nTotDesc,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture PesqPict("SC7","C7_VLDESC",14, mv_par12)

	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"

	// Posiciona o Arquivo de Empresa SM0.                          

	cAlias := Alias()
	dbSelectArea("SM0")
	dbSetOrder(1)   // forca o indice na ordem certa
	nRegistro := Recno()
	dbSeek(SUBS(cNumEmp,1,2)+SC7->C7_FILENT)

	// Imprime endereco de entrega do SM0 somente se o MV_PAR13 =" "

	// RICARDO LIMA - 23/11/17 | AJUSTE NO LAYOUT
	If Empty(MV_PAR13)
		@ li,003 PSAY STR0008 + Substr(ALLTRIM(SM0->M0_ENDENT),1,38)		//"Local de Entrega  : "
		@ li,062 PSAY "-"
		@ li,066 PSAY ALLTRIM(SM0->M0_CIDENT)
		@ li,088 PSAY "-"
		@ li,090 PSAY ALLTRIM(SM0->M0_ESTENT)
		@ li,093 PSAY "-"
		@ li,095 PSAY STR0009	//"CEP :"
		@ li,101 PSAY Trans(Alltrim(SM0->M0_CEPENT),cCepPict)
	Else
		@ li,003 PSAY STR0008 + MV_PAR13		//"Local de Entrega  : " imprime o endereco digitado na pergunte
	Endif

	@ li,142 - nDifColCC PSAY "|"
	dbGoto(nRegistro)
	dbSelectArea( cAlias )

	li++
	// RICARDO LIMA - 23/11/17 | AJUSTE NO LAYOUT
	@ li,001 PSAY "|"
	@ li,003 PSAY STR0010 + Substr(SM0->M0_ENDCOB,1,38)		//"Local de Cobranca : "
	@ li,062 PSAY "-"
	@ li,066 PSAY ALLTRIM(SM0->M0_CIDCOB)
	@ li,088 PSAY "-"
	@ li,090 PSAY ALLTRIM(SM0->M0_ESTCOB)
	@ li,093 PSAY "-"
	@ li,095 PSAY STR0009	//"CEP :"
	@ li,101 PSAY Trans(Alltrim(SM0->M0_CEPCOB),cCepPict)
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"

	// inicio da rotina que captura o nome do solicitante
	if !empty(SC7->C7_NUMSC)
	dbSelectArea("SC1")
	dbSetOrder(1)  // Nº SOLICITAÇÃO
	dbSeek(xFilial("SC1")+SC7->C7_NUMSC)
	IF !FOUND()
		cSolic := " "
	ELSE           
		cSolic := SUBSTR(SC1->C1_SOLICIT,1,30)
	ENDIF
	ENDIF   
	// final da rotina 

	dbSelectArea("SE4")
	dbSetOrder(1)
	dbSeek(xFilial("SE4")+SC7->C7_COND)
	dbSelectArea("SC7")
	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY STR0011+SubStr(SE4->E4_COND,1,40)		//"Condicao de Pagto "
	@ li,061 PSAY STR0012		//"|Data de Emissao|"
	@ li,079 PSAY STR0013		//"Total das Mercadorias : " 
	//@ li,108 PSAY xMoeda(nTotal,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotal,14,MsDecimais(MV_PAR12))
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY SubStr(SE4->E4_DESCRI,1,34)
	@ li,061 PSAY "|"
	@ li,066 PSAY SC7->C7_EMISSAO
	@ li,077 PSAY "|"
	If cPaisLoc<>"BRA"
		@ li,079 PSAY OemtoAnsi(STR0063)	//"Total de los Impuestos : "
	//	@ li,108 PSAY xMoeda(nValIVA,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nValIVA,14,MsDecimais(MV_PAR12))
	Else
		@ li,079 PSAY STR0064		//"Total com Impostos : "
	//	@ li,108 PSAY xMoeda(nTotMerc,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotMerc,14,MsDecimais(MV_PAR12))
	Endif
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",53)
	@ li,055 PSAY Replicate("-",86 - nDifColCC)
	@ li,142 - nDifColCC PSAY "|"
	li++
	dbSelectArea("SM4")
	dbSetOrder(1)
	dbSeek(xFilial("SM4")+SC7->C7_REAJUST)
	dbSelectArea("SC7")   

	@ li,001 PSAY "|"
	@ li,003 PSAY STR0014		//"Reajuste :"
	//@ li,014 PSAY SC7->C7_REAJUST Picture PesqPict("SC7","c7_reajust",,mv_par12)
	//@ li,018 PSAY SM4->M4_DESCR

	If cPaisLoc == "BRA"
		@ li,054 PSAY STR0015		//"| IPI   :"
	//	@ li,064 PSAY xMoeda(nTotIPI,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotIpi,14,MsDecimais(MV_PAR12))
		@ li,088 PSAY "| ICMS   : "
	//	@ li,100 PSAY xMoeda(nTotIcms,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotIcms,14,MsDecimais(MV_PAR12))
		@ li,142 - nDifColCC PSAY "|"
	Else	
		@ li,054 PSAY "|"
		@ li,142 - nDifColCC PSAY "|"
	EndIf

	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",52)
	@ li,054 PSAY (STR0049) //"| Frete :"
	//@ li,064 PSAY xMoeda(nTotFrete,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotFrete,14,MsDecimais(MV_PAR12))
	@ li,088 PSAY (STR0058) //"| Despesas :"
	//@ li,100 PSAY xMoeda(nTotDesp,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotDesp,14,MsDecimais(MV_PAR12))

	@ li,142 - nDifColCC PSAY "|"

	// Inicializar campos de Observacoes.                           

	// inicio da rotina que captura o nome do solicitante
	if !empty(SC7->C7_NUMSC)
		dbSelectArea("SC1")
		dbSetOrder(1)  // Nº SOLICITAÇÃO
		dbSeek(xFilial("SC1")+SC7->C7_NUMSC)			
		IF !FOUND()
			cSolic := " "
		ELSE    
			cSolic := SUBSTR(SC1->C1_SOLICIT,1,30)
		ENDIF                
	endif   
	// final da rotina 	

	If Empty(cObs02)
		If Len(cObs01) > 50
			cObs := cObs01
			cObs01 := Substr(cObs,1,50)
			For nX := 2 To 4
				cVar  := "cObs"+StrZero(nX,2)
				&cVar := Substr(cObs,(50*(nX-1))+1,50)
			Next
		EndIf
	Else
		cObs01:= Substr(cObs01,1,IIf(Len(cObs01)<50,Len(cObs01),50))
		cObs02:= Substr(cObs02,1,IIf(Len(cObs02)<50,Len(cObs01),50))
		cObs03:= Substr(cObs03,1,IIf(Len(cObs03)<50,Len(cObs01),50))
		cObs04:= Substr(cObs04,1,IIf(Len(cObs04)<50,Len(cObs01),50))
	EndIf

	dbSelectArea("SC7")
	If !Empty(C7_APROV)
		lNewAlc := .T.
		cComprador := UsrFullName(SC7->C7_USER)
		If C7_CONAPRO != "B"
			lLiber := .T.
		EndIf                    

	// inicio darotina que captura o nome do solicitante
	if !empty(SC7->C7_NUMSC)
		dbSelectArea("SC1")
		dbSetOrder(1)  // Nº SOLICITAÇÃO
		dbSeek(xFilial("SC1")+SC7->C7_NUMSC)			
		IF !FOUND()
			cSolic := " "
		ELSE     
			cSolic := SUBSTR(SC1->C1_SOLICIT,1,30)
		ENDIF
	endif      
	// final da rotina 	

		dbSelectArea("SCR")
		dbSetOrder(1)
		dbSeek(xFilial("SCR")+"PC"+SC7->C7_NUM)
		While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM)==xFilial("SCR")+Alltrim(SC7->C7_NUM) .And. SCR->CR_TIPO == "PC"
			cAprov += AllTrim(UsrFullName(SCR->CR_USER))+" ["
			Do Case
				Case SCR->CR_STATUS=="03" //Liberado
					cAprov += "Ok"
				Case SCR->CR_STATUS=="04" //Bloqueado
					cAprov += "BLQ"
				Case SCR->CR_STATUS=="05" //Nivel Liberado
					cAprov += "##"
				OtherWise                 //Aguar.Lib
					cAprov += "??"
			EndCase
			cAprov += "] - "
			dbSelectArea("SCR")
			dbSkip()
		Enddo
		If !Empty(SC7->C7_GRUPCOM)
			dbSelectArea("SAJ")
			dbSetOrder(1)
			dbSeek(xFilial("SAJ")+SC7->C7_GRUPCOM)
			While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+SC7->C7_GRUPCOM
				If SAJ->AJ_USER != SC7->C7_USER
					cAlter += AllTrim(UsrFullName(SAJ->AJ_USER))+"/"
				EndIf
				dbSelectArea("SAJ")
				dbSkip()
			EndDo
		EndIf

		
	EndIf

	li++
	@ li,001 PSAY STR0016		//"| Observacoes"
	@ li,054 PSAY STR0017		//"| Grupo :"
	@ li,088 PSAY STR0059      //"| SEGURO :"
	//@ li,100 PSAY xMoeda(nTotSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotSeguro,14,MsDecimais(MV_PAR12))
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY cObs01
	@ li,054 PSAY "|"+Replicate("-",86 - nDifColCC)
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY cObs02
	@ li,054 PSAY STR0018		//"| Total Geral : "

	If !lNewAlc
	//	@ li,094 PSAY xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotalNF,14,MsDecimais(MV_PAR12))
	Else
		If lLiber
	//		@ li,094 PSAY xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotalNF,14,MsDecimais(MV_PAR12))
		Else
			@ li,080 PSAY (STR0051)
		EndIf
	EndIf

	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY cObs03
	@ li,054 PSAY "|"+Replicate("-",86 - nDifColCC)
	@ li,142 - nDifColCC PSAY "|"
	li++

	If !lNewAlc
		@ li,001 PSAY "|"
		@ li,003 PSAY cObs04
		@ li,054 PSAY "|"
		@ li,061 PSAY STR0019		//"|           Liberacao do Pedido"
		@ li,102 PSAY STR0020		//"| Obs. do Frete: "
		//	@ li,119 PSAY IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF"," " ))
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY "|"+Replicate("-",59)
		@ li,061 PSAY "|"
		@ li,102 PSAY "|"
		@ li,142 - nDifColCC PSAY "|"

		li++
		cLiberador := ""
		nPosicao := 0
		//	@ li,001 PSAY "|"
		//	@ li,007 PSAY STR0021		//"Comprador"
		//	@ li,003 PSAY STR0021		//"Comprador"
		//	@ li,021 PSAY "|"
		//	@ li,028 PSAY STR0022		//"Gerencia"
		//	@ li,041 PSAY "|"
		//	@ li,046 PSAY STR0023		//"Diretoria"
		//	@ li,061 PSAY "|     ------------------------------"
		//	@ li,102 PSAY "|"
		//
		@ li,001 PSAY "|"
		@ li,003 PSAY STR0021		//"Comprador"
		@ li,013 PSAY "|"
		@ li,015 PSAY STR0022		//"Gerencia"
		@ li,025 PSAY "|"
		@ li,027 PSAY STR0023		//"Diretoria"
		@ li,037 PSAY "|"
		@ li,040 PSAY "   Solicitante"
		@ li,061 PSAY "|     ------------------------------"
		@ li,102 PSAY "|"
		//	     
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY "|"            
		@ li,002 PSAY cComprador
		@ li,013 PSAY "|"
		@ li,025 PSAY "|"
		@ li,037 PSAY "|" 
		@ li,040 PSAY cSolic  
		@ li,061 PSAY "|     " + R110Center(cLiberador) // 30 posicoes
		@ li,102 PSAY "|"
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY "|"
		@ li,002 PSAY Replicate("-",limite)
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY STR0024		//"|   NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY "|"
		@ li,002 PSAY Replicate("-",limite)
		@ li,142 - nDifColCC PSAY "|"

		//Everson - 13/04/2020. Chamado 057146.
		li++
		@ li,001 PSAY "|   Relatório gerado às " + Time() + " em " + DToC(Date())	+ "."
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY "|"
		@ li,002 PSAY Replicate("-",limite)
		@ li,142 - nDifColCC PSAY "|"
		//

	Else
		@ li,001 PSAY "|"
		@ li,003 PSAY cObs04
		@ li,054 PSAY "|"
		@ li,059 PSAY IF(lLiber,STR0050,STR0051)		//"     P E D I D O   L I B E R A D O"#"|     P E D I D O   B L O Q U E A D O !!!"
		@ li,102 PSAY STR0020		//"| Obs. do Frete: "
		//	@ li,119 PSAY IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF"," " ))
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY "|"+Replicate("-",99)
		@ li,102 PSAY "|"
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY "|"
		@ li,003 PSAY STR0052		//"Comprador Responsavel :"
		@ li,027 PSAY Substr(cComprador,1,60)
		@ li,088 PSAY "|"
		@ li,089 PSAY STR0060      //"BLQ:Bloqueado"
		@ li,102 PSAY "|"
		@ li,142 - nDifColCC PSAY "|"
		li++
		nAuxLin := Len(cAlter)
		@ li,001 PSAY "|"
		@ li,003 PSAY STR0053		//"Compradores Alternativos :"
		While nAuxLin > 0 .Or. lImpLeg
			@ li,029 PSAY Substr(cAlter,Len(cAlter)-nAuxLin+1,60)
			@ li,088 PSAY "|"
			If lImpLeg
				@ li,089 PSAY STR0061   //"Ok:Liberado"
				lImpLeg := .F.
			EndIf
			@ li,102 PSAY "|"
			@ li,142 - nDifColCC PSAY "|"
			nAuxLin -= 60
			li++
		EndDo
		nAuxLin := Len(cAprov)
		lImpLeg := .T.
		While nAuxLin > 0	.Or. lImpLeg
			@ li,001 PSAY "|"
			If lImpLeg  // Imprimir soh a 1a vez
				@ li,003 PSAY STR0054		//"Aprovador(es) :"
			EndIf
			@ li,018 PSAY Substr(cAprov,Len(cAprov)-nAuxLin+1,70)
			@ li,088 PSAY "|"
			If lImpLeg2  // Imprimir soh a 2a vez
				@ li,089 PSAY STR0067 //"##:Nivel.Lib"
				lImpLeg2 := .F.
			EndIf
			If lImpLeg   // Imprimir soh a 1a vez
				@ li,089 PSAY STR0062  //"??:Aguar.Lib"
				lImpLeg  := .F.
				lImpLeg2 := .T.
			EndIf
			@ li,102 PSAY "|"
			@ li,142 - nDifColCC PSAY "|"
			nAuxLin -=70
			li++
		EndDo
		// IMPRIME O NOME DO SOLICITANTE / PEDIDO 013876
		@ li,001 PSAY "|"
		@ li,003 PSAY "Solicitante:"        
		@ li,016 PSAY Substr(ALLTRIM(cSolic),1,30)  
		//		
		If lImpLeg2
			lImpLeg2 := .F.
		//		@ li,001 PSAY "|"
			@ li,087 PSAY "|"
			@ li,088 PSAY STR0067 //"##:Nivel Lib"
			@ li,101 PSAY "|"
			@ li,141 - nDifColCC PSAY "|"
			li++
		EndIf
		If nAuxLin == 0
			li++
		EndIf
		@ li,001 PSAY "|"
		@ li,002 PSAY Replicate("-",limite)
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY STR0024		//"|   NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY "|"
		@ li,002 PSAY Replicate("-",limite)
		@ li,142 - nDifColCC PSAY "|"

		//Everson - 13/04/2020. Chamado 057146.
		li++
		@ li,001 PSAY "|   Relatório gerado às " + Time() + " em " + DToC(Date())	+ "."
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY "|"
		@ li,002 PSAY Replicate("-",limite)
		@ li,142 - nDifColCC PSAY "|"
		//

	EndIf

Return .T.

Static Function FinalAE(nDescProd)

	Local nk := 1
	Local nX := 0
	Local nTotDesc:= nDescProd
	Local nTotNF	:= MaFisRet(,'NF_TOTAL')
	Local nTxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
	cMensagem:= Formula(C7_MSG)

	If !Empty(cMensagem)
		li++
		@ li,001 PSAY "|"
		@ li,002 PSAY Padc(cMensagem,129)
		@ li,142 - nDifColCC PSAY "|"
	Endif
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"
	li++
	While li<39
		@ li,001 PSAY "|"
		@ li,006 PSAY "|"
		@ li,022 PSAY "|"
		@ li,022 + nk PSAY "*"
		nk := IIf( nk == 32 , 1 , nk + 1 )
		@ li,049 PSAY "|"
		@ li,052 PSAY "|"
		@ li,065 PSAY "|"
		@ li,080 PSAY "|"
		@ li,097 PSAY "|"
		@ li,108 PSAY "|"
		@ li,142 - nDifColCC PSAY "|"
		li++
	EndDo
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"

	// Posiciona o Arquivo de Empresa SM0.                          

	cAlias := Alias()
	dbSelectArea("SM0")
	dbSetOrder(1)   // forca o indice na ordem certa
	nRegistro := Recno()
	dbSeek(SUBS(cNumEmp,1,2)+SC7->C7_FILENT)

	// Imprime endereco de entrega do SM0 somente se o MV_PAR13 =" "

	If Empty(MV_PAR13)
		@ li,003 PSAY STR0008 + SM0->M0_ENDENT		//"Local de Entrega  : "
		@ li,057 PSAY "-"
		@ li,061 PSAY SM0->M0_CIDENT
		@ li,083 PSAY "-"
		@ li,085 PSAY SM0->M0_ESTENT
		@ li,088 PSAY "-"
		@ li,090 PSAY STR0009	//"CEP :"
		@ li,096 PSAY Trans(Alltrim(SM0->M0_CEPENT),cCepPict)
	Else
		@ li,003 PSAY STR0008 + MV_PAR13		//"Local de Entrega  : " imprime o endereco digitado na pergunte
	Endif

	@ li,142 - nDifColCC PSAY "|"
	dbGoto(nRegistro)
	dbSelectArea(cAlias)

	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY STR0010 + SM0->M0_ENDCOB		//"Local de Cobranca : "
	@ li,057 PSAY "-"
	@ li,061 PSAY SM0->M0_CIDCOB
	@ li,083 PSAY "-"
	@ li,085 PSAY SM0->M0_ESTCOB
	@ li,088 PSAY "-"
	@ li,090 PSAY STR0009	//"CEP :"
	@ li,096 PSAY Trans(Alltrim(SM0->M0_CEPCOB),cCepPict)
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"

	dbSelectArea("SE4")
	dbSetOrder(1)
	dbSeek(xFilial("SE4")+SC7->C7_COND)
	dbSelectArea("SC7")
	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY STR0011+SubStr(SE4->E4_COND,1,15)		//"Condicao de Pagto "
	@ li,038 PSAY STR0012		// "|Data de Emissao|"
	@ li,056 PSAY STR0013		// "Total das Mercadorias : "
	//@ li,094 PSAY xMoeda(nTotal,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotal,14,MsDecimais(MV_PAR12))

	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY SubStr(SE4->E4_DESCRI,1,34)
	@ li,038 PSAY "|"
	@ li,043 PSAY SC7->C7_EMISSAO
	@ li,054 PSAY "|"
	@ li,056 PSAY STR0064		// "Total com Impostos : "
	//@ li,094 PSAY xMoeda(nTotMerc,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda) Picture tm(nTotMerc,14,MsDecimais(MV_PAR12))
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",52)
	@ li,054 PSAY "|"
	@ li,055 PSAY Replicate("-",86 - nDifColCC)
	@ li,142 - nDifColCC PSAY "|"
	li++
	dbSelectArea("SM4")
	dbSeek(xFilial("SM4")+SC7->C7_REAJUST)
	dbSelectArea("SC7")
	@ li,001 PSAY "|"
	@ li,003 PSAY STR0014		//"Reajuste :"
	@ li,014 PSAY SC7->C7_REAJUST Picture PesqPict("SC7","c7_reajust",,mv_par12)
	@ li,018 PSAY SM4->M4_DESCR
	@ li,054 PSAY STR0018		//"| Total Geral : "

	//@ li,094 PSAY xMoeda(nTotNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,,nTxMoeda)      Picture tm(nTotNF,14,MsDecimais(MV_PAR12))
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"

	// Inicializar campos de Observacoes.                           

	If Empty(cObs02)
		If Len(cObs01) > 50
			cObs 	:= cObs01
			cObs01:= Substr(cObs,1,50)
			For nX := 2 To 4
				cVar  := "cObs"+StrZero(nX,2)
				&cVar := Substr(cObs,(50*(nX-1))+1,50)
			Next
		EndIf
	Else
		cObs01:= Substr(cObs01,1,IIf(Len(cObs01)<50,Len(cObs01),50))
		cObs02:= Substr(cObs02,1,IIf(Len(cObs02)<50,Len(cObs01),50))
		cObs03:= Substr(cObs03,1,IIf(Len(cObs03)<50,Len(cObs01),50))
		cObs04:= Substr(cObs04,1,IIf(Len(cObs04)<50,Len(cObs01),50))
	EndIf

	li++
	@ li,001 PSAY STR0025	//"| Observacoes"
	@ li,054 PSAY STR0026	//"| Comprador    "
	@ li,070 PSAY STR0027	//"| Gerencia     "
	@ li,085 PSAY STR0028	//"| Diretoria    "
	@ li,142 - nDifColCC PSAY "|"

	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY cObs01
	@ li,054 PSAY "|"
	@ li,070 PSAY "|"
	@ li,085 PSAY "|"
	@ li,142 - nDifColCC PSAY "|"

	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY cObs02
	@ li,054 PSAY "|"
	@ li,070 PSAY "|"
	@ li,085 PSAY "|"
	@ li,142 - nDifColCC PSAY "|"

	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY cObs03
	@ li,054 PSAY "|"
	@ li,070 PSAY "|"
	@ li,085 PSAY "|"
	@ li,142 - nDifColCC PSAY "|"

	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY cObs04
	@ li,054 PSAY "|"
	@ li,070 PSAY "|"
	@ li,085 PSAY "|"
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY STR0029	//"|   NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"

Return .T.

Static Function ImpRodape()

	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,070 PSAY STR0030		//"Continua ..."
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"
	li:=0

Return .T.

Static Function ImpCabec(ncw)

	Local nOrden, cCGC
	LOCAL cMoeda

	cMoeda := Iif(mv_par12<10,Str(mv_par12,1),Str(mv_par12,2))

	@ 01,001 PSAY "|"
	@ 01,002 PSAY Replicate("-",limite)
	@ 01,142 - nDifColCC PSAY "|"
	@ 02,001 PSAY "|"
	@ 02,029 PSAY IIf(nOrdem>1,(STR0033)," ")		//" - continuacao"

	If mv_par08 == 1
		@ 02,045 PSAY (STR0031)+" - Via Cega"	//"| P E D I D O  D E  C O M P R A S"
	Else
		@ 02,045 PSAY (STR0032)+" - Via Cega" //"| A U T. D E  E N T R E G A     "
	EndIf

	If ( Mv_PAR08==2 )
		@ 02,090 PSAY "|"
		@ 02,093 PSAY SC7->C7_NUMSC + "/" + SC7->C7_NUM  //    Picture PesqPict("SC7","c7_num")	
	Else
		@ 02,096 PSAY "|"
		@ 02,101 PSAY SC7->C7_NUM      Picture PesqPict("SC7","c7_num")
	EndIf

	@ 02,107 PSAY "/"+Str(nOrdem,1)
	@ 02,112 PSAY IIf(SC7->C7_QTDREEM>0,Str(SC7->C7_QTDREEM+1,2)+STR0034+Str(ncw,2)+STR0035," ")		//"a.Emissao "###"a.VIA"
	@ 02,142 - nDifColCC PSAY "|"
	@ 03,001 PSAY "|"
	@ 03,003 PSAY ALLTRIM(SM0->M0_NOMECOM)  // RICARDO LIMA - 23/11/17 | AJUSTE NO LAYOUT
	@ 03,045 PSAY "|"+Replicate("-",95 - nDifColCC)
	@ 03,142 - nDifColCC PSAY "|"
	@ 04,001 PSAY "|"
	@ 04,003 PSAY Substr(SM0->M0_ENDENT,1,42)
	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)
	@ 04,045 PSAY "|"
	If ( cPaisLoc$"ARG|POR|EUA" )
		@ 04,047 PSAY Substr(SA2->A2_NOME,1,35)+"-"+SA2->A2_COD+"-"+SA2->A2_LOJA	
	Else
		@ 04,047 PSAY Substr(SA2->A2_NOME,1,35)+"-"+SA2->A2_COD+"-"+SA2->A2_LOJA+(STR0036)+" " + SA2->A2_INSCR		//" I.E.: "	
	EndIf
	@ 04,142 - nDifColCC PSAY "|"
	@ 05,001 PSAY "|"
	@ 05,003 PSAY (STR0009)+Trans(SM0->M0_CEPENT,cCepPict)+" - "+Trim(SM0->M0_CIDENT)+" - "+SM0->M0_ESTENT		//"CEP :"
	@ 05,045 PSAY "|"
	@ 05,047 PSAY SubStr(SA2->A2_END,1,42)   Picture PesqPict("SA2","A2_END")
	@ 05,089 PSAY "-  "+SubStr(Trim(SA2->A2_BAIRRO),1,(53-nDifColCC))	Picture "@!"
	@ 05,142 - nDifColCC PSAY "|"
	@ 06,001 PSAY "|"
	@ 06,003 PSAY STR0037+SM0->M0_TEL		//"TEL: "
	@ 06,023 PSAY STR0038+SM0->M0_FAX		//"FAX: "
	@ 06,045 PSAY "|"
	@ 06,047 PSAY Trim(SA2->A2_MUN)  Picture "@!"
	@ 06,069 PSAY SA2->A2_EST    		Picture PesqPict("SA2","A2_EST")
	@ 06,074 PSAY STR0009	//"CEP :"
	@ 06,081 PSAY SA2->A2_CEP    		Picture PesqPict("SA2","A2_CEP")

	dbSelectArea("SX3")
	nOrden = IndexOrd()
	dbSetOrder(2)
	dbSeek("A2_CGC")
	cCGC := Alltrim(X3TITULO())
	@ 06,093 PSAY cCGC //"CGC: "
	dbSetOrder(nOrden)

	dbSelectArea("SA2")
	@ 06,103 PSAY SA2->A2_CGC    		Picture PesqPict("SA2","A2_CGC")
	@ 06,142 - nDifColCC PSAY "|"
	@ 07,001 PSAY "|"
	@ 07,002 PSAY (cCGC) + " "+ Transform(SM0->M0_CGC,cCgcPict)		//"CGC: "
	If cPaisLoc == "BRA"
		@ 07,029 PSAY (STR0041)+ InscrEst()		//"IE:"
	EndIf
	@ 07,045 PSAY "|"
	@ 07,047 PSAY SC7->C7_CONTATO Picture PesqPict("SC7","C7_CONTATO")
	@ 07,069 PSAY STR0042	//"FONE: "
	@ 07,075 PSAY "("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15)
	@ 07,100 PSAY (STR0038)	//"FAX: "
	@ 07,106 PSAY "("+Substr(SA2->A2_DDD,1,3)+") "+SubStr(SA2->A2_FAX,1,15)
	@ 07,142 - nDifColCC PSAY "|"
	@ 08,001 PSAY "|"
	@ 08,002 PSAY Replicate("-",limite)
	@ 08,142 - nDifColCC PSAY "|"

	If mv_par08 == 1
		@ 09,001 PSAY "|"
		@ 09,002 PSAY STR0043	//"Itm|"
		@ 09,009 PSAY STR0044	//"Codigo      "
		@ 09,022 PSAY STR0045	//"|Descricao do Material"
		
		//Everson - 16/08/2019. Chamado 050939.
		//@ 09,049 PSAY STR0046	//"|UM|  Quant." //Everson - 16/08/2019. Chamado 050939.
		@ 09,065 PSAY "               |UM   |Quant.          | Entrega  |  C.C.   | S.C. |"	//"|UM|  Quant." 
		
		//Everson - 16/08/2019. Chamado 050939.
	/*	If cPaisLoc <> "BRA"
			@ 09,065 PSAY IIF(nDifColcc == 0,STR0056,STR0057)	//"|Valor Unitario|      Valor Total   |Entrega   |  C.C.   | S.C. |"
		Else
			@ 09,065 PSAY IIF(nDifColcc == 0,STR0047,STR0055)	//"|Valor Unitario|IPI% |  Valor Total   | Entrega  |  C.C.   | S.C. |"
		EndIf*/
		//
		
		@ 10,001 PSAY "|"
		@ 10,002 PSAY Replicate("-",limite)
		@ 10,142 - nDifColCC PSAY "|"
	Else
		@ 09,001 PSAY "|"
		@ 09,002 PSAY STR0043	//"Itm|"
		@ 09,009 PSAY STR0044	//"Codigo      "
		@ 09,022 PSAY STR0045	//"|Descricao do Material"
		
		//Everson - 16/08/2019. Chamado 050939.
		//@ 09,049 PSAY STR0046	//"|UM|  Quant."
		@ 09,065 PSAY "               |UM   |Quant.          | Entrega  |  C.C.   | S.C. |"	//"|UM|  Quant."
		
		//Everson - 16/08/2019. Chamado 050939.
		//@ 09,065 PSAY STR0048	//"|Valor Unitario|  Valor Total   |Entrega | Numero da OP  "
		//
		
		@ 09,142 - nDifColCC PSAY "|"
		@ 10,001 PSAY "|"
		@ 10,002 PSAY Replicate("-",limite)
		@ 10,142 - nDifColCC PSAY "|"
	EndIf
	dbSelectArea("SC7")
	li := 10

Return .T.

Static Function R110Center(cLiberador)

Return( Space((30-Len(AllTrim(cLiberador)))/2)+AllTrim(cLiberador) )

Static Function AjustaSX1()

	Local aHelpPor	:= {}
	Local aHelpEng	:= {}
	Local aHelpSpa	:= {}

	Aadd( aHelpPor, "Filtra os itens do PC a serem impressos " )
	Aadd( aHelpPor, "Todos,somente os abertos ou Atendidos.  " )

	Aadd( aHelpEng, "                                        " )
	Aadd( aHelpEng, "                                        " )

	Aadd( aHelpSpa, "                                        " )
	Aadd( aHelpSpa, "                                        " )

	PutSx1(cPerg,"14","Lista quais ?       ","Cuales Lista ?      ","List which ?        ","mv_che","N",1,0,1,"C","","","","","mv_par14",;
	"Todos ","Todos ","All ","","Em Aberto ","En abierto ","Open ","Atendidos ","Atendidos ","Serviced ","","","","","","","","","","")
	PutSX1Help("P.MTR11014.",aHelpPor,aHelpEng,aHelpSpa)

Return

USER Function ChkPerg110(cUserId,cGrupo,cSeq)

	Local aArea  := GetArea()
	Local cRet   := Nil
	Local cParam := "MV_PAR"+cSeq

	U_ADINF009P('ADMTR110' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Pedido de Compras / Autorizacao de Entrega Especifico Adoro para atender solicitacao Rosangela')

	dbSelectArea("SXK")
	dbSetOrder(2)
	If dbSeek("U"+cUserId+cGrupo+cSeq)
		If ValType(&cParam) == "C"
			cRet := AllTrim(SXK->XK_CONTEUD)
		ElseIf 	ValType(&cParam) == "N"
			cRet := Val(AllTrim(SXK->XK_CONTEUD))
		ElseIf 	ValType(&cParam) == "D"
			cRet := CTOD((AllTrim(SXK->XK_CONTEUD)))
		Endif
	Endif

	RestArea(aArea)

Return(cRet)  

Static Function R110FIniPC(cPedido,cItem,cSequen,cFiltro)

	Local aArea		:= GetArea()
	Local aAreaSC7	:= SC7->(GetArea())
	Local cValid		:= ""
	Local nPosRef		:= 0
	Local nItem		:= 0
	Local cItemDe		:= IIf(cItem==Nil,'',cItem)
	Local cItemAte	:= IIf(cItem==Nil,Repl('Z',Len(SC7->C7_ITEM)),cItem)
	Local cRefCols	:= ''
	DEFAULT cSequen	:= ""
	DEFAULT cFiltro	:= ""

	dbSelectArea("SC7")
	dbSetOrder(1)
	If dbSeek(xFilial("SC7")+cPedido+cItemDe+Alltrim(cSequen))
		MaFisEnd()
		MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})
		While !Eof() .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+cPedido .AND. ;
				SC7->C7_ITEM <= cItemAte .AND. (Empty(cSequen) .OR. cSequen == SC7->C7_SEQUEN)

			// Nao processar os Impostos se o item possuir residuo eliminado  
			If &cFiltro
				dbSelectArea('SC7')
				dbSkip()
				Loop
			EndIf
				
			// Inicia a Carga do item nas funcoes MATXFIS  
			nItem++
			MaFisIniLoad(nItem)
			dbSelectArea("SX3")
			dbSetOrder(1)
			dbSeek('SC7')
			While !EOF() .AND. (X3_ARQUIVO == 'SC7')
				cValid	:= StrTran(UPPER(SX3->X3_VALID)," ","")
				cValid	:= StrTran(cValid,"'",'"')

				If "MAFISREF" $ cValid .AND. ALLTRIM(SX3->X3_CAMPO) <> 'C7_OPER' // CHAMADO 055493 - WILLIAM COSTA - 03/02/2020
					nPosRef  := AT('MAFISREF("',cValid) + 10
					cRefCols := Substr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
					// Carrega os valores direto do SC7.           
					MaFisLoad(cRefCols,&("SC7->"+ SX3->X3_CAMPO),nItem)
				EndIf
				dbSkip()
			End
			MaFisEndLoad(nItem,2)
			dbSelectArea('SC7')
			dbSkip()
		End
	EndIf

	RestArea(aAreaSC7)
	RestArea(aArea)

Return .T.