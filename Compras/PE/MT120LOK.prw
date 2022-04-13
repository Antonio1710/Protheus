#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"

/*/{Protheus.doc} User Function MT120LOK
	Ponto de Entrada para validar a existencia de centros de custos com aprovadores diferentes
	@type  Function
	@author Almir Bandina
	@since 05/03/2008
	@version 01
	@history Chamado 046284 - FWNM         - 08/01/2019 - Novas regras alteracao valor
	@history Chamado 046887 - Ricardo Lima - 01/02/2019 - Desobriga a classe de valor para a RNX2
	@history Chamado 047931 - FWNM         - 19/03/2019 - Centro Custo x Lote - RNX2
	@history Chamado 048414 - FWNM         - 10/04/2019 - Notas - Lote RNX2
	@history Chamado TI     - FWNM         - 18/10/2019 - Projetos investimentos - Considerar despesas inseridas no rodape, tais como frete, despesas e outros
	@history Chamado TI     - FWNM         - 21/10/2019 - Projetos investimentos - Considerar moedas estrangeiras
	@history Chamado 053363 - FWNM         - 19/11/2019 - 053363 || OS 054733 || CONTROLADORIA || DAIANE || (16)2106-3549 || PC X PROJETO
	@history Chamado 053444 - FWNM         - 19/11/2019 - 053444 || OS 054835 || SUPRIMENTOS || EVANDRA || 8362 || PC EM EURO
	@history Chamado 054834 - FWNM         - 09/01/2020 - OS 056235 || TECNOLOGIA || LUIZ || 8451 || PEDIDO DE COMPRA
	@history Chamado 056397 - FWNM         - 06/03/2020 - OS 057849 || ADM || BRUNA || 8446 || CLASSE VALOR- EXPORT
	@history Chamado 056397 - FWNM         - 10/03/2020 - OS 057849 || ADM || BRUNA || 8446 || CLASSE VALOR- EXPORT - Desabilitar a��es realizadas ap�s reuni�o de alinhamento que participaram Danielle e Bruna (Log�stica)
	@history Chamado 057611 - Everson 	   - 23/04/2020 - Tratamento para obter apenas os grupos de aprova��o que n�o est�o bloqueados.
	@history Chamado   2562 - Everson      - 04/11/2020 - Tratamento para gravar o n�mero do estudo do projeto.
	@history ticket    8582 - Fernando Mac - 08/02/2021 - Replicar OP na pr�xima linha
	@history ticket   10573 - Fernando Mac - 08/03/2021 - Ponto de Corre��o - Manuten��o de Ativos
	@history ticket   63516 - Fer Macieira - 09/11/2021 - Refor�o para gravar campo C7_XTXMOEDA utilizado para montar o consumo/saldo do projeto de investimento
	@history ticket   68971 - Fer Macieira - 02/03/2022 - Integra��o Notas Centro de Custo 5134 - Item 113
	@history ticket   71057 - Fer Macieira - 08/04/2022 - Item cont�bil Lan�amentos da Filial 0B - Itapira
/*/
User Function MT120LOK()

	//�����������������������������������������������������������������������������������������Ŀ
	//� Define as vari�veis utilizadas na rotina                                                �
	//�������������������������������������������������������������������������������������������
	Local aAreaAtu1	:= GetArea()
	Local lRetorno	:= .T.
	Local aAprov	:= {}
	Local nLoop		:= 0
	Local nPConta	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_CONTA" } )
	Local nPCusto	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_CC" } )
	Local nPItemCta	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_ITEMCTA" } )
	Local nPClasse	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_CLVL" } )
	Local nPTotal	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_TOTAL" } )
	Local nPProjeto	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_PROJETO" } )
	Local nPProduto	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_PRODUTO" } )
	Local nCodProj  := aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_CODPROJ" } )
	Local nPNumSC   := aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_NUMSC" } )
	Local nPItemSC  := aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_ITEMSC" } )
	Local nPQuant	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_QUANT" } )
	Local cConta	:= aCols[n,nPConta]
	Local cCusto	:= aCols[n,nPCusto]
	Local cItemCta	:= aCols[n,nPItemCta]
	Local cClasse	:= aCols[n,nPClasse]
	Local nTotal	:= aCols[n,nPTotal]
	Local cProjeto	:= aCols[n,nPProjeto]
	Local cProduto	:= aCols[n,nPProduto]
	Local cCodProj	:= aCols[n,nCodProj]
	Local cNumSC	:= aCols[n,nPNumSC]
	Local cItemSC	:= aCols[n,nPItemSC]
	Local nQuant	:= aCols[n,nPQuant]
	Local nQtdSol	:= 0
	
	// FWNM - 16/02/2018 - Projetos Investimentos
	Local lSldAtv   := GetMV("MV_#PRJSLD",,".T.")
	Local cFasePrj  := GetMV("MV_PRJINIC",,"05")
	
	// Chamado n. 046284
	Local cFaseRej := GetMV("MV_#FASREJ",,"01")
	Local cFaseApr := GetMV("MV_#FASEOK",,"03")
	//  

	//Everson - 04/11/2020. Chamado 2562.
	Local nItemEst := aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_XITEMST" } )
	//

	Local nxTxMoed := 0 // 053444 || OS 054835 || SUPRIMENTOS || EVANDRA || 8362 || PC EM EURO - FWNM - 19/11/2019
	Local cMVItemCta := ""
	
	Private lPrjInvest := Left(AllTrim(cCusto),1) == "9"
	
	if cmodulo = "EEC" //Incluido por Adriana para desconsiderar a validacao quando pedido incluido pelo modulo EEC
		// Chamado n. 056397 || OS 057849 || ADM || BRUNA || 8446 || CLASSE VALOR- EXPORT - FWNM - 10/03/2020
		/*
		// Chamado n. 056397 || OS 057849 || ADM || BRUNA || 8446 || CLASSE VALOR- EXPORT - FWNM - 06/03/2020
		If AF8->(FieldPos("EET_XCLVL")) > 0
			gdFieldPut("C7_CLVL", EET->EET_XCLVL, n)
		EndIf
		//
		*/
		Return .T.
	endif
	
	// Validacao incluida em 23/05/2014 - por Adriana - chamado 19220
	If (cEmpAnt == "01" .And. xFilial("SC7") = "03")
		If Alltrim(acols[n,npcusto]) == "8001" .and. !Empty(cNumSC)
			nQtdSol := Posicione("SC1",1,xFilial("SC1")+cNumSC+cItemSC,"C1_QUANT")
			if nQuant <> nQtdSol
				Aviso(	"MT120LOK",;
				"Quantidade no Pedido: "+Alltrim(transform(nQuant,"@E 99999999.9999"))+" � diferente da Quantidade Solicitada: "+;
				Alltrim(transform(nQtdSol,"@E 99999999.9999"))+".",;
				{ "&Retorna" },,;
				"Diverg�ncia PC x SC" )
				lRetorno	:= .F.
			endif
		endif
	endif
	//
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Se deixou o centro de custo em branco n�o permite inclus�o                              �
	//�������������������������������������������������������������������������������������������
	If lRetorno .And. Empty( cCusto )
		Aviso(	"MT120LOK-01",;
		"� obrigat�rio o preenchimento do Centro de Custo.",;
		{ "&Retorna" },,;
		"Conte�do em Branco" )
		lRetorno	:= .F.
	EndIf
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Se deixou o item cont�bil em branco n�o permite inclus�o                                �
	//�������������������������������������������������������������������������������������������
	If lRetorno .And. Empty( cItemCta )
		Aviso(	"MT120LOK-02",;
		"� obrigat�rio o preenchimento do Item Cont�bil.",;
		{ "&Retorna" },,;
		"Conte�do em Branco" )
		lRetorno	:= .F.
	EndIf
	
	// Chamado n. 056397 || OS 057849 || ADM || BRUNA || 8446 || CLASSE VALOR- EXPORT - FWNM - 10/03/2020
	/*
	//�����������������������������������������������������������������������������������������Ŀ
	//� Obriga informar a classe de valor se a conta iniciar por 31 e o centro de custo por 6   �
	//�������������������������������������������������������������������������������������������
	// Ricardo Lima-01/02/2019-CH:046887
	if cEmpAnt <> '07'
		If SubStr( cConta, 1, 2 ) == "31" .And. SubStr ( cCusto, 1, 1 ) == "6" .And. Empty( SubStr( cClasse, 1, 1 ) )
			Aviso(	"MT120LOK-03",;
			"Conta Cont�bil: " + AllTrim( cConta ) + " Centro de Custo: " + cCusto + "." + Chr(13) + Chr(10) +;
			"� obrigat�rio o preenchimento da Classe de Valor.",;
			{ "&Retorna" },,;
			"Conte�do em Branco" )
			lRetorno	:= .F.
		EndIf
	Endif
	*/
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Obriga informar o projeto se o centro de custo iniciar por 9                            �
	//�������������������������������������������������������������������������������������������
	If SubStr( cCusto, 1, 1) == "9" .And. Empty( cProjeto )
		Aviso(	"MT120LOK-04",;
		"Centro de Custo: " + cCusto + "." + Chr(13) + Chr(10) +;
		"� obrigat�rio o preenchimento do Projeto.",;
		{ "&Retorna" },,;
		"Conte�do em Branco" )
		lRetorno	:= .F.
		//MSGSTOP( "Obrigat�rio preenchimento Cod. Projeto", "ATEN��O", "ALERT")
		//_lRet := .F.
	EndIf
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Se o centro de custo nao iniciar por 9 nao pode haver codigo do projeto.Mauricio        �
	//�������������������������������������������������������������������������������������������
	If !Empty(cProjeto) .And. SubStr( cCusto, 1, 1) <> "9"
		Aviso(	"MT120LOK-05",;
		"Centro de Custo: " + cCusto + "." + Chr(13) + Chr(10) +;
		"Nao pode ter o campo projeto preenchido.",;
		{ "&Retorna" },,;
		"Conte�do em Branco" )
		lRetorno	:= .F.
	EndIf
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Faz verificacao se o projeto se encontra encerrado ou nao para aceitar lancamento       �
	//�������������������������������������������������������������������������������������������
	
	DbSelectArea("AF8")
	DbSetOrder(1)
	if dbseek(xFilial("AF8")+cProjeto)
		if AF8->AF8_ENCPRJ == "1"
			Aviso(	"MT120LOK-06",;
			"Projeto: " + cProjeto + "." + Chr(13) + Chr(10) +;
			"Projeto ja se encontra encerrado. Deve ser utilizado outro projeto",;
			{ "&Retorna" },,;
			"" )
			lRetorno	:= .F.
		endif

		//Everson - 04/11/2020. Chamado 2562.
		If lRetorno .And. Upper(Alltrim(cValToChar(AF8->AF8_XESTUD))) == "S" .And. Empty(Alltrim(cValToChar(aCols[n,nItemEst])))
			Aviso(	"MT120LOK-26",;
			"Projeto: " + cProjeto + "." + Chr(13) + Chr(10) +;
			"Necess�rio informar o item de estudo do projeto.",;
			{ "&Retorna" },,;
			"" )
			lRetorno	:= .F.
					
		EndIf
		//

	EndIf
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Obriga informar o codigo do projeto se o campo Projeto estiver preenchido               �
	//�������������������������������������������������������������������������������������������
	If cEmpAnt == "01"
		If !Empty( cProjeto ) .And. Empty(cCodProj)
			Aviso(	"MT120LOK-07",;
			"Projeto: " + cProjeto + "." + Chr(13) + Chr(10) +;
			"� obrigat�rio o preenchimento do Codigo do Projeto.",;
			{ "&Retorna" },,;
			"Conte�do em Branco" )
			lRetorno	:= .F.
		ElseIf Empty( cProjeto ) .And. !Empty(cCodProj)
			aCols[n,aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CODPROJ"})] := ""
		EndIf
	Endif
	
	//Incluido 01/08/12
	//�����������������������������������������������������������������������������������������Ŀ
	//� Valida centro de custo 8001, sendo obrigatorio ter solicitacao de compra amarrada - Chamado 014362�
	//�������������������������������������������������������������������������������������������
	If (cEmpAnt == "01" .And. cFilAnt = "03") .Or. cEmpAnt == "07"
		If Alltrim(aCols[n,aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CC"})]) == "8001"
			If Empty (aCols[n,aScan(aHeader,{|x| AllTrim(x[2]) == "C7_NUMSC"})])
				Aviso(	"MT120LOK-08",;
				"Centro de custo 8001 s� pode ser utilizado se amarrado a uma solicita��o de compras." + Chr(13) + Chr(10) +;
				"� Obrigatorio informar a solicita��o de compras.",;
				{ "&Retorna" },,;
				"Solicitacao de Compras n�o amarrada" )
				lRetorno	:= .F.
			Endif
		EndIf
	Endif
	
	//////////////////////////////////////////////////////////
	// Projetos - FWNM - 16/02/2018
	//////////////////////////////////////////////////////////

	// Consiste exig�ncia ou n�o do projeto - FWNM 16/03/2018
	cCC := gdFieldGet("C7_CC", n)
	
	// @history ticket   68971 - Fer Macieira - 02/03/2022 - Integra��o Notas Centro de Custo 5134 - Item 113
	cMVItemCta := GetMV("MV_#ITM113",,"113")
	If AllTrim(cCC) $ GetMV("MV_#CC5134",,"5134")
		gdFieldPut("C7_ITEMCTA", cMVItemCta, n)
	EndIf
	//

	// @history ticket 71057 - Fernando Macieira - 08/04/2022 - Item cont�bil Lan�amentos da Filial 0B - Itapira
	If AllTrim(cEmpAnt) == "01" .and. AllTrim(cFilAnt) == "0B"
		cMVItemCta := AllTrim(GetMV("MV_#ITAFIL",,"125"))
		gdFieldPut("C7_ITEMCTA", cMVItemCta, n)
	EndIf
	//

	lPrjInv := Left(AllTrim(cCC),1) == "9"
	
	// Qdo prj for investimento
	If lPrjInv .and. !Alltrim(cCC) $ GetMV("MV_#CCPADR")
		
		If Empty(cProjeto)
			lRetorno := .f.
			
			Aviso(	"MT120LOK-09",;
			"Centro de Custo: " + cCC + "." + Chr(13) + Chr(10) +;
			"� obrigat�rio o preenchimento do Projeto.",;
			{ "&Retorna" },,;
			"Conte�do em Branco" )
		EndIf
		
		// Consiste CC permitidos para aquele projeto (ZC1)
		If lRetorno
			
			ZC1->( dbSetOrder(1) ) // ZC1_FILIAL+ZC1_PROJET+ZC1_CC
			If ZC1->( !dbSeek(xFilial("ZC1")+cProjeto+cCusto) )
				
				lRetorno := .f.
				
				Aviso(	"MT120LOK-13",;
				"Centro Custo n�o permitido para este projeto! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
				"CC: " + cCusto + " - " + Posicione("CTT",1,xFilial("CTT")+cCusto,"CTT_DESC01") + chr(13) + chr(10) +;
				"Projeto: " + cProjeto + " - " + AF8->AF8_DESCRI,;
				{ "&Retorna" },,;
				"Projeto x CC permitidos" )
				
			EndIf
			
		EndIf
		
		// Consiste filial/planta permitida para aquele CC
		If lRetorno
			
			If Left(AllTrim(cProjeto),2) <> cFilAnt
				
				lRetorno := .f.
				
				Aviso(	"MT120LOK-14",;
				"Este projeto n. " + AllTrim(cProjeto) + " n�o pertence a esta filial! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
				"Filial/Planta: " + cFilAnt + chr(13) + chr(10) +;
				"Projeto/Planta: " + Left(AllTrim(cProjeto),2),;
				{ "&Retorna" },,;
				"Projeto x Filial/Planta" )
				
			EndIf
			
		EndIf
		
		// consiste valor/saldo, fase e vigencia
		If lRetorno
			
			// Controle Saldo Projeto ativo
			If lSldAtv
				
				AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
				AF8->( dbSeek(xFilial("AF8")+cProjeto) )
				
				// Consiste apenas projetos que possuem valor
				If AF8->AF8_XVALOR > 0
					
					// Consiste fase do projeto para checar se esta na central de aprovacao
					//If AllTrim(cFasePrj) == AllTrim(AF8->AF8_FASE) // Chamado n. 046284				
					If AllTrim(AF8->AF8_FASE) <> AllTrim(cFaseApr) // Se fase diferente de aprovada // Chamado n. 046284				
						lRetorno := .f.
						
						Aviso(	"MT120LOK-25",;
						"Projeto n. " + AllTrim(cProjeto) + " n�o foi aprovado na Central de Aprova��o! " + chr(13) + chr(10) + "Uso ainda n�o permitido..." + chr(13) + chr(10) + ;
						"",;
						{ "&Retorna" },,;
						"Projeto n�o aprovado" )
						
					EndIf
					
					// Consiste saldo informado no pedido de compras x saldo do projeto (AF8)
					If lRetorno
						
						cPC     := cA120Num
						cPCItem := gdFieldGet("C7_ITEM", n)
						
						cPCItemKey := ""
						cPCItemKey := cPC+cPCItem
						
						nSldPrj := u_ADCOM017P(cProjeto,,cPCItemKey)
						//nSldPrj := u_ADCOM017P(cProjeto)
						
						nTt     := gdFieldGet("C7_TOTAL", n)
						nDesc   := gdFieldGet("C7_VLDESC", n)

						// Chamado TI - Consistir valores adicionais tais como IPI, ICMS ST e outros que compoem total da NF - FWNM - 18/10/2019
						nValIPI   := gdFieldGet("C7_VALIPI",n)
						nValICMST := gdFieldGet("C7_ICMSRET",n)
						nQtdItem  := gdFieldGet("C7_QUANT",n)
						nValRoda  := 0 //aValores[8] // Frete + Despesas + Seguro

						nTtPrj := (nTt + nValIPI + nValICMST + nValRoda - nDesc)
						//nTtPrj := (nTt - nDesc)
						// 
						
						// Chamado TI - Moedas estrangeiras - FWNM - 21/10/2019
						If nMoedaPed <> 1 // Real
							
							nxTxMoed := UpSM2() // 053444 || OS 054835 || SUPRIMENTOS || EVANDRA || 8362 || PC EM EURO - FWNM - 19/11/2019
							
							// Consisto e Gravo taxa da moeda que sera utilizado na rotina de consumo/saldo dos projetos de investimentos
							If nxTxMoed <= 0
								lRetorno := .f.
								msgInfo("[MT120LOK-24] - PC em moeda estrangeira! Necess�rio informar a taxa no cadastro de moedas para poder finalizar o PC...")
							Else
								gdFieldPut("C7_XTXMOED", nxTxMoed, n)
								
								// Calculo o pedido que esta sendo movimentado com Taxa encontrada
								nTtPrj := nTtPrj * nxTxMoed
							EndIf
						
						EndIf
						//
						
						If lRetorno
						
							If nTtPrj > nSldPrj
								
								lRetorno := .f.
								
								Aviso(	"MT120LOK-11",;
								"Saldo do projeto n. " + AllTrim(cProjeto) + " insuficiente! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
								"[PC] L�quido: " + Transform(nTtPrj, PesqPict("SC7","C7_TOTAL")) + chr(13) + chr(10) +;
								"[PRJ] Saldo: " + Transform(nSldPrj, PesqPict("SC7","C7_VLDESC")),;
								{ "&Retorna" },,;
								"Projeto sem saldo" )
								
							EndIf
						
						EndIf
						
					EndIf
					
					// Consiste datas previstas do projeto (AF8) x data de digita��o oriunda do servidor do documento
					If lRetorno
						
						dDtDig := msDate()
						
						If dDtDig < AF8->AF8_START .or. dDtDig > AF8->AF8_FINISH
							
							lRetorno := .f.
							
							Aviso(	"MT120LOK-12",;
							"Vig�ncia do projeto n. " + AllTrim(cProjeto) + " est� fora! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
							"Data Digita��o: " + DtoC(dDtDig) + chr(13) + chr(10) +;
							"In�cio-Fim Projeto: " + DtoC(AF8->AF8_START) + " - " + DtoC(AF8->AF8_FINISH),;
							{ "&Retorna" },,;
							"Vig�ncia do Projeto" )
							
						EndIf
						
					EndIf
					
				EndIf
				
			EndIf
			
		EndIf
		
	Else
		
		If !Empty(cProjeto)
			lRetorno := .f.
			
			Aviso(	"MT120LOK-10",;
			"Centro de Custo: " + cCC + "." + Chr(13) + Chr(10) +;
			"N�o permitido o preenchimento do Projeto.",;
			{ "&Retorna" },,;
			"N�o permitido informar projeto para CC que n�o � investimento" )
		EndIf
		
	EndIf
	
	// FWNM - 23/03/2018 - Totaliza projetos informados nos itens para confrontar com o saldo do mesmo
	If lRetorno
		
		// Controle Saldo Projeto ativo
		If lSldAtv
			
			aTtPrj := {} // armazenar� os dados do projeto para totalizar e consistir
			
			For i:=1 to Len(aCols)
				
				If !gdDeleted(i)
					
					cPrj    := gdFieldGet("C7_PROJETO", i)
					
					If !Empty(cPrj)
						
						// Projeto Investimento
						cCC     := gdFieldGet("C7_CC", i)
						lPrjInv := Left(AllTrim(cCC),1) == "9"
						
						If lPrjInv .and. !Alltrim(cCC) $ GetMV("MV_#CCPADR")
							
							nTt     := gdFieldGet("C7_TOTAL", i)
							nDesc   := gdFieldGet("C7_VLDESC", i)
							cPC     := cA120Num
							cPCItem := gdFieldGet("C7_ITEM", i)
							
							// Chamado TI - Consistir valores adicionais tais como IPI, ICMS ST e outros que compoem total da NF - FWNM - 18/10/2019
							nValIPI   := gdFieldGet("C7_VALIPI",i)
							nValICMST := gdFieldGet("C7_ICMSRET",i)

							// Valor do projeto do item
							nTtPrj := (nTt + nValIPI + nValICMST - nDesc)
							//nTtPrj := (nTt - nDesc)
							//

							aAdd( aTtPrj, {	cPrj,;
							nTtPrj ,;
							cPC ,;
							cPCItem } )
							
						EndIf
						
					EndIf
					
				EndIf
				
			Next i
			
			// Ordena por Projeto + PC + Item PC
			aSort( aTtPrj,,, { |x,y| x[1]+x[3]+x[4] < y[1]+y[3]+y[4] } )
			
			cColsPrj := ""
			nColsTot := 0
			cColsPC     := ""
			cColsPCItem := ""
	
			cPCItemKey  := ""
			
			For y:=1 to Len(aTtPrj)
	
				cColsPC      := aTtPrj[y,3]
				cColsPCItem  := aTtPrj[y,4]
				
				cPCItemKey    += cColsPC + cColsPCItem + "|"
				
				If y == 1 // primeira linha
					cColsPrj := aTtPrj[y,1]
					nColsTot := aTtPrj[y,2]
					
				Else
					// Se for o mesmo projeto
					If cColsPrj == aTtPrj[y,1]
						nColsTot += aTtPrj[y,2] // totalizo os valores
						
						// Consisto saldo x total dos itens
					Else
						
						AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
						If AF8->( dbSeek(xFilial("AF8")+cColsPrj) )
							
							// Consiste apenas projetos que possuem valor
							If AF8->AF8_XVALOR > 0
								
								// Consiste saldo informado no documento de entrada x saldo do projeto (AF8)
								//nSldPrj := u_ADCOM017P(cColsPrj)
								nSldPrj := u_ADCOM017P(cColsPrj,,cPCItemKey)
								
								// Chamado TI - Consistir valores adicionais tais como IPI, ICMS ST e outros que compoem total da NF - FWNM - 18/10/2019
								nValRoda  := aValores[8] // Frete + Despesas + Seguro
								nColsTot := nColsTot + nValRoda
								//

								// Chamado TI - Moedas estrangeiras - FWNM - 21/10/2019
								If nMoedaPed <> 1 // Real
									// Calculo o pedido que esta sendo movimentado com Taxa encontrada
									nColsTot := nColsTot * nxTxMoed
								EndIf
								//

								If nColsTot > nSldPrj
									
									lRetorno := .f.
									
									Aviso(	"MT120LOK-22",;
									"Saldo do projeto n. " + AllTrim(cColsPrj) + " insuficiente! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
									"[PC] Tt L�quido itens: " + Transform(nColsTot, PesqPict("SC7","C7_TOTAL")) + chr(13) + chr(10) +;
									"[PRJ] Saldo: " + Transform(nSldPrj, PesqPict("SC7","C7_TOTAL")),;
									{ "&Retorna" },,;
									"Projeto sem saldo" )
									
								Else
									// zero variaveis para proximo projeto
									cColsPrj := aTtPrj[y,1]
									nColsTot := aTtPrj[y,2]
									cColsPC      := aTtPrj[y,3]
									cColsPCItem  := aTtPrj[y,4]
									
								EndIf
								
							EndIf
							
						EndIf
						
					EndIf
					
				EndIf
				
			Next y
			
			// Consisto o �ltimo projeto do acols - N�O RETIRAR !!!
			If lRetorno
				
				If !Empty(cColsPrj) // Chamado n. 053363 || OS 054733 || CONTROLADORIA || DAIANE || (16)2106-3549 || PC X PROJETO - FWNM - 19/11/2019
				
					AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
					If AF8->( dbSeek(xFilial("AF8")+cColsPrj) )
						
						// Consiste apenas projetos que possuem valor
						If AF8->AF8_XVALOR > 0
							
							// Consiste saldo informado no documento de entrada x saldo do projeto (AF8)
							nSldPrj := u_ADCOM017P(cColsPrj,,cPCItemKey)
							
							// Chamado TI - Consistir valores adicionais tais como IPI, ICMS ST e outros que compoem total da NF - FWNM - 18/10/2019
							nValRoda  := aValores[8] // Frete + Despesas + Seguro
							nColsTot := nColsTot + nValRoda
							//

							// Chamado TI - Moedas estrangeiras - FWNM - 21/10/2019
							If nMoedaPed <> 1 // Real
								// Calculo o pedido que esta sendo movimentado com Taxa encontrada
								nColsTot := nColsTot * nxTxMoed
							EndIf
							//

							If nColsTot > nSldPrj
								
								lRetorno := .f.
								
								Aviso(	"MT120LOK-23",;
								"Saldo do projeto n. " + AllTrim(cColsPrj) + " insuficiente! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
								"[PC] Tt L�quido itens: " + Transform(nColsTot, PesqPict("SC7","C7_TOTAL")) + chr(13) + chr(10) +;
								"[PRJ] Saldo: " + Transform(nSldPrj, PesqPict("SC7","C7_TOTAL")),;
								{ "&Retorna" },,;
								"Projeto sem saldo" )
								
							EndIf
							
						EndIf
						
					EndIf

				EndIf
				
			EndIf
			
		EndIf
		
	EndIf
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Verifica se todos os itens tem o mesmo grupo de aprova��o em fun��o do centro de custo  �
	//� e item cont�bil                                                                         �
	//�������������������������������������������������������������������������������������������
	If lRetorno
		
		//�������������������������������������������������������������������������������������Ŀ
		//� S� valida se houver mais de um elemento no aCols                                    �
		//���������������������������������������������������������������������������������������
		If Len( aCols ) > 0
			
			//���������������������������������������������������������������������������������Ŀ
			//� Obtem a estrutura de aprova��o do centro de custo da linha posicionada          �
			//�����������������������������������������������������������������������������������

			// Chamado n. 054834 || OS 056235 || TECNOLOGIA || LUIZ || 8451 || PEDIDO DE COMPRA - FWNM - 09/01/2020
			nTotal := 0
			For i := 1 To Len(aCols)

				If !gdDeleted(i)

					nTotal += gdFieldGet("C7_TOTAL",i)

					// @history ticket   63516 - Fer Macieira - 09/11/2021 - Refor�o para gravar campo C7_XTXMOEDA utilizado para montar o consumo/saldo do projeto de investimento
					If nMoedaPed <> 1 .and. !Empty(gdFieldGet("C7_PROJETO", i))

						If nxTxMoed <= 0
							lRetorno := .f.
							msgInfo("[MT120LOK-MOEDA] - PC em moeda estrangeira! Necess�rio informar a taxa no cadastro de moedas para poder finalizar o PC...")
							Return lRetorno
						Else
							gdFieldPut("C7_XTXMOED", nxTxMoed, i)
						EndIf
						
					EndIf
					//

				EndIf

			Next i
			//
			
			aAprov	:= U_GetAprov( cCusto, cItemCta, nTotal, cProduto )
			
			//���������������������������������������������������������������������������������Ŀ
			//� Se n�o encontrar aprovador, n�o deixa colocar o pedido                          �
			//�����������������������������������������������������������������������������������
			If Len( aAprov ) == 0
				Aviso(	"MT120LOK-15",;
				"N�o foi localizado controle de al�ada para o centro de custo/Item Cont�bil.",;
				{ "&Retorna" },,;
				"C.Custo/Item: " + cCusto + "/" + cItemCta )
				lRetorno	:= .F.
				
			Else
				
				//���������������������������������������������������������������������������������Ŀ
				//� Varre todo o array para valida��o                                               �
				//�����������������������������������������������������������������������������������
				For nLoop := 1 To Len( aCols )
					
					//�����������������������������������������������������������������������������Ŀ
					//� S� valida se n�o for a linha posicionada                                    �
					//�������������������������������������������������������������������������������
					If !( aCols[nLoop,Len( aHeader ) + 1] ) .And. nLoop <> n
						lRetorno	:= VldCCusto( aCols[nLoop,nPCusto], cCusto, aCols[nLoop,nPItemCta], cItemCta, aAprov, nTotal )
					EndIf
					
					//�����������������������������������������������������������������������������Ŀ
					//� Se teve erro na valida��o aborta retornando inv�lido                        �
					//�������������������������������������������������������������������������������
					If !lRetorno
						Exit
					EndIf
					
				Next nLoop
				
			EndIf
			
		EndIf
		
	EndIf
	
	// Chamado n. 047931 || OS 049195 || CONTROLADORIA || ANDRESSA || 45968437 || C.CUSTO X LOTE -RNX2 - FWNM - 19/03/2019
	If lRetorno
		lRetorno := ChkZCN()
	EndIf
	// 

	//@history ticket 10573 - Fernando Macieira - 08/03/2021 - Ponto de Corre��o - Manuten��o de Ativos
	If lRetorno
		lRetorno := ChkCCOP()
	EndIf
	//

	RestArea(aAreaAtu1)

Return( lRetorno )

/*/{Protheus.doc} User Function GETAPROV
	Funcao para obter os aprovadores para um centro de custo com aprovadores diferentes
	@type  Function
	@author Almir Bandina    
	@since 05/03/2008
	@version 01
	@history Chamado TI - Almir Bandina - 17/07/2008 - Tratamento para grupo de produto
/*/
User Function GetAprov( cCusto, cItemCta, nTotPed, cProduto )

	//�����������������������������������������������������������������������������������������Ŀ
	//� Define as vari�veis utilizadas na rotina                                                �
	//�������������������������������������������������������������������������������������������
	Local aAreaAtu	:= GetArea()
	Local aAreaPAF	:= PAF->( GetArea() )
	Local aAreaPAG	:= PAG->( GetArea() )
	Local aAreaPAH	:= PAH->( GetArea() )
	Local aAprov	:= {}
	Local nVlrMin	:= 0
	Local nLoop1	:= 0
	Local cQry		:= ""
	Local cTipLib	:= "V"
	Local cAprov	:= ""
	
	Default	nTotPed	:= 0
	//�����������������������������������������������������������������������������������������Ŀ
	//� Monta a string da query para pesquisar o grupo de aprova��o                             �
	//�������������������������������������������������������������������������������������������
	cQry	:= " SELECT PAF.R_E_C_N_O_ AS REGPAF"
	cQry	+= " FROM " + RetSqlName( "PAF" ) + " PAF (NOLOCK)"
	cQry	+= " WHERE PAF.PAF_FILIAL = '" + xFilial( "PAF" ) + "'"
	cQry	+= " AND PAF.PAF_CCINI <= '" + cCusto   + "'"
	cQry	+= " AND PAF.PAF_CCFIM >= '" + cCusto   + "'"
	cQry	+= " AND PAF.PAF_ITINI <= '" + cItemCta + "'"
	cQry	+= " AND PAF.PAF_ITFIM >= '" + cItemCta + "'"

	cQry	+= " AND PAF.PAF_MSBLQL <> '1' " //Everson - 23/04/2020. Chamado 057611.

	cQry	+= " AND PAF.D_E_L_E_T_ = ' '"
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Verifica se o alias esta em uso                                                         �
	//�������������������������������������������������������������������������������������������
	If Select( "PAFTMP" ) > 0
		dbSelectArea( "PAFTMP" )
		dbCloseArea()
	EndIf
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Compatibiliza a query com o banco de dados em uso                                       �
	//�������������������������������������������������������������������������������������������
	cQry	:= ChangeQuery( cQry )
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Executa a query para obter os dados                                                     �
	//�������������������������������������������������������������������������������������������
	TCQUERY cQry NEW ALIAS "PAFTMP"
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Verifica se encontou algum grupo de aprova��o                                           �
	//�������������������������������������������������������������������������������������������
	dbSelectArea( "PAFTMP" )
	dbGoTop()
	If !Eof()
		
		//�������������������������������������������������������������������������������������Ŀ
		//� Posiciona no cabecalho do grupo de aprova��o                                        �
		//���������������������������������������������������������������������������������������
		dbSelectArea( "PAF" )
		dbGoTo( PAFTMP->REGPAF )
		
		//�������������������������������������������������������������������������������������Ŀ
		//� Posiciona nos itens do grupo de aprova��o                                           �
		//���������������������������������������������������������������������������������������
		dbSelectArea( "PAG" )
		dbSetOrder( 1 )
		MsSeek( xFilial( "PAG" ) + PAF->PAF_CODGRP )
		While !Eof() .And. PAG->PAG_FILIAL == xFilial( "PAG" ) .And. PAG->PAG_CODGRP == PAF->PAF_CODGRP
			
			//���������������������������������������������������������������������������������Ŀ
			//� Verifica se o registro esta bloqueado                                           �
			//�����������������������������������������������������������������������������������
			If PAG->PAG_MSBLQL == "1"
				dbSelectArea( "PAG" )
				dbSkip()
				Loop
			EndIf
			
			//���������������������������������������������������������������������������������Ŀ
			//� Define o aprovador padr�o                                                       �
			//�����������������������������������������������������������������������������������
			cAprov	:= PAG->PAG_IDUSER
			
			//���������������������������������������������������������������������������������Ŀ
			//� Verifica se existe aprovador substituto para o per�odo                          �
			//�����������������������������������������������������������������������������������
			dbSelectArea( "PAH" )
			dbSetOrder( 1 )
			MsSeek( xFilial( "PAH" ) + PAG->PAG_CODGRP + PAG->PAG_IDUSER )
			While !Eof() .And. PAH->PAH_FILIAL == xFilial( "PAH" ) .And.;
				PAH->PAH_CODGRP == PAG->PAG_CODGRP .And.;
				PAH->PAH_APROFI == PAG->PAG_IDUSER
				
				//�����������������������������������������������������������������������������Ŀ
				//� Verifica se a data do server esta dentro do per�odo de aus�ncia             �
				//�������������������������������������������������������������������������������
				If MsDate() >= PAH->PAH_DATINI .And. MsDate() <= PAH->PAH_DATFIM
					cAprov	:= PAH->PAH_APRSUB
				EndIf
				
				dbSelectArea( "PAH" )
				dbSkip()
			EndDo
			
			//���������������������������������������������������������������������������������Ŀ
			//� Define e tipo de liberador para o centro de custo em fun��o do valor            �
			//�����������������������������������������������������������������������������������
			If nTotPed >= PAG->PAG_VLRINI .And. nTotPed <= PAG->PAG_VLRFIM
				cTipLib	:= "A"
			Else
				cTipLib	:= "V"
			EndIf
			
			
			//���������������������������������������������������������������������������������Ŀ
			//� Alimenta arry com os liberadores seja vistador ou aprovador                     �
			//�����������������������������������������������������������������������������������
			aAdd( aAprov, {	PAG->PAG_CODGRP,;
			cAprov,;
			PAG->PAG_NIVEL,;
			cTipLib,;
			PAG->PAG_VLRINI,;
			PAG->PAG_VLRFIM } )
			
			If cTipLib == "A"
				Exit
			EndIf
			
			dbSelectArea( "PAG" )
			dbSkip()
			
		EndDo
		
	EndIf
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Restaura as �reas originais                                                             �
	//�������������������������������������������������������������������������������������������
	dbSelectArea( "PAFTMP" )
	dbCloseArea()
	RestArea( aAreaPAF )
	RestArea( aAreaPAG )
	RestArea( aAreaPAH )
	RestArea( aAreaAtu )

Return( aAprov )

/*/{Protheus.doc} Static Function VLDCCUSTO
	Funcao para validar se o centro de custo digitado tem a mesma estrutura de aprovacao dos demais centros de custos
	@type  Function
	@author Almir Bandina
	@since 05/03/2008
	@version 01
	@history 
/*/
Static Function VldCCusto( cCCLinha, cCCOrig, cItLinha, cItOrig, aAprov, nTotal )

	//�����������������������������������������������������������������������������������������Ŀ
	//� Define as vari�veis utilizadas na rotina                                                �
	//�������������������������������������������������������������������������������������������
	Local aAux		:= U_GetAprov( cCCLinha, cItLinha, nTotal )
	Local lRetorno	:= .T.
	Local nLoop		:= 0
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Varre o array auxiliar e procura no array de aprovadores se existe                      �
	//�������������������������������������������������������������������������������������������
	
	// FWNM - 17/11/2017
	
	/*
	
	(Chamado n. 038160)
	
	Regras Definidas:
	
	- As regras atuais n�o ser�o modificadas para os pedidos de compras que n�o forem projetos de investimentos;
	
	- As regras atuais ser�o modificadas somente para os pedidos de compras que forem projetos de investimentos, respeitando os crit�rios abaixo:
	
	a)	Os itens do pedido de compras sejam projetos de investimentos (CC iniciado com 9 ou campo projeto);
	b)	N�o permitir num �nico pedido de compras itens com e sem projeto;
	c)	N�o permitir a confirma��o do pedido de compras quando as al�adas dos grupos de aprova��es forem diferentes em n�vel, aprovador e valor.
	
	*/
	
	//If lPrjInvest // Chamado n. 054834 || OS 056235 || TECNOLOGIA || LUIZ || 8451 || PEDIDO DE COMPRA - FWNM - 09/01/2020
		
		//If cCCLinha <> cCCOrig // Chamado n. 054834 || OS 056235 || TECNOLOGIA || LUIZ || 8451 || PEDIDO DE COMPRA - FWNM - 09/01/2020
			
			cCodMsg := ""
			cDetalh := ""
			
			For nLoop := 1 To Len( aAux )
				
				If aScan( aAprov, { |x| x[2] == aAux[nLoop,2] } ) == 0 // APROVADOR CONTIDO DENTRO DO GRUPO DE APROVACAO
					lRetorno	:= .F.
					cCodMsg := "Aprovadores distintos "
					cDetalh += "N�vel " + aAprov[nLoop,3] + chr(13) + chr(10)
					cDetalh += "Grupos Aprova��es: " + aAprov[nLoop,1] + " x " + aAux[nLoop,1] + chr(13) + chr(10)
					cDetalh += "Aprovadores: " + aAprov[nLoop,2] + " x " + aAux[nLoop,2] + chr(13) + chr(10)
					Exit
				Else
					cDetalh += "N�vel " + aAprov[nLoop,3] + chr(13) + chr(10)
					cDetalh += "Grupos Aprova��es: " + aAprov[nLoop,1] + " x " + aAux[nLoop,1] + chr(13) + chr(10)
					cDetalh += "Aprovadores: " + aAprov[nLoop,2] + " x " + aAux[nLoop,2] + chr(13) + chr(10)
				EndIf
				
				
				// Consiste alcada niveis, Aprovador/Vistador e valores - qdo mesmo aprovador em grupos de aprovacoes distintos
				
				// Nivel
				If aScan( aAprov, { |x| x[2]+x[3] == aAux[nLoop,2]+aAux[nLoop,3] } ) == 0
					lRetorno	:= .F.
					cCodMsg := "Aprovadores iguais com n�veis distintos "
					cDetalh += "N�veis: " + aAprov[nLoop,3] + " x " + aAux[nLoop,3] + chr(13) + chr(10)
					Exit
				EndIf

				
				// Chamado n. 054834 || OS 056235 || TECNOLOGIA || LUIZ || 8451 || PEDIDO DE COMPRA - FWNM - 09/01/2020
				
				// Status (Aprovador/Vistador)
				If aScan( aAprov, { |x| x[2]+x[4] == aAux[nLoop,2]+aAux[nLoop,4] } ) == 0
					lRetorno	:= .F.
					cCodMsg := "Aprovadores iguais com status distintos (Aprovador/Vistador) "
					cDetalh += "Status: " + aAprov[nLoop,4] + " x " + aAux[nLoop,4] + chr(13) + chr(10)
					Exit
				EndIf
				
				/*
				// Valor Minimo
				If aScan( aAprov, { |x| Val(x[2])+x[5] == Val(aAux[nLoop,2])+aAux[nLoop,5] } ) == 0
					lRetorno	:= .F.
					cCodMsg := "Aprovadores iguais com valores m�nimos distintos "
					cDetalh += "Valores M�nimos: " + Alltrim(Transform(aAprov[nLoop,5],PesqPict("PAG","PAG_VLRINI"))) + " x " + Alltrim(Transform(aAux[nLoop,5],PesqPict("PAG","PAG_VLRINI"))) + chr(13) + chr(10)
					Exit
				EndIf
				
				// Valor Maximo
				If aScan( aAprov, { |x| Val(x[2])+x[6] == Val(aAux[nLoop,2])+aAux[nLoop,6] } ) == 0
					lRetorno	:= .F.
					cCodMsg := "Aprovadores iguais com valores m�ximos distintos "
					cDetalh += "Valores M�ximos: " + Alltrim(Transform(aAprov[nLoop,6],PesqPict("PAG","PAG_VLRFIM"))) + " x " + Alltrim(Transform(aAux[nLoop,6],PesqPict("PAG","PAG_VLRFIM"))) + chr(13) + chr(10)
					Exit
				EndIf
				*/

				//
				
			Next nLoop
			
			//�����������������������������������������������������������������������������������������Ŀ
			//� Faz a interface com o usu�rio da diverg�ncia de estrutura de aprova��o                  �
			//�������������������������������������������������������������������������������������������
			If !lRetorno
				Aviso(	"MT120LOK-16",;
				cCodMsg + "para o centro de custo/Item Cont�bil informado." + Chr(13) + Chr(10) +;
				"Selecione um centro de custo/Item Cont�bil com a mesma estrutura de aprova��o." + chr(13) + chr(10) + chr(13) + chr(10) +;
				cDetalh,;
				{ "&Retorna" }, 3,;
				"Centro de Custo/Item (Origem): " + AllTrim(cCCOrig) + "/" + AllTrim(cItOrig) )
			EndIf
			
		//EndIf
		
	
	//Else
		
		/*
		For nLoop := 1 To Len( aAux )
			// Chamado n. 054834 || OS 056235 || TECNOLOGIA || LUIZ || 8451 || PEDIDO DE COMPRA - fwnm - 09/01/2020
			//If aScan( aAprov, { |x| x[1] == aAux[nLoop,01] } ) == 0 // GRUPO APROVACAO 
			If aScan( aAprov, { |x| x[2] == aAux[nLoop,2] } ) == 0 .or.; // Aprovador
			   aScan( aAprov, { |x| x[3] == aAux[nLoop,3] } ) == 0 .or.; // Nivel
			   aScan( aAprov, { |x| x[4] == aAux[nLoop,4] } ) == 0 .or.; // Status (Aprovador/Vistador)
			   aScan( aAprov, { |x| x[5] == aAux[nLoop,5] } ) == 0 .or.; // Valor Inicial
			   aScan( aAprov, { |x| x[6] == aAux[nLoop,6] } ) == 0       // Valor Final
				lRetorno	:= .F.
				Exit
			EndIf
		Next nLoop
		
		//�����������������������������������������������������������������������������������������Ŀ
		//� Faz a interface com o usu�rio da diverg�ncia de estrutura de aprova��o                  �
		//�������������������������������������������������������������������������������������������
		If !lRetorno
			Aviso(	"MT120LOK-17",;
			"Existem aprovadores diferentes para o centro de custo/Item Cont�bil informado." + Chr(13) + Chr(10) +;
			"Selecione um centro de custo/Item Cont�bil com a mesma estrutura de aprova��o.",;
			{ "&Retorna" }, 2,;
			"Centro de Custo/Item: " + cCCOrig + "/" + cItOrig )
		EndIf
		*/
		
	//EndIf

Return( lRetorno )

/*/{Protheus.doc} User Function VLDUSR2CC
	Funcao para validar se o usuario esta autorizado a associar o centro de custo                     
	@type  Function
	@author Almir Bandina
	@since 05/03/2008
	@version 01
	@history Chamado TI - Almir Bandina - 17/07/2008 - Tratamento nas altera��es de centro de custo quando o campo cotacao estiver preenchido
/*/
User Function VldUsr2CC( cCCusto )
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Define as vari�veis utilizadas na rotina                                                �
	//�������������������������������������������������������������������������������������������
	Local aAreaAtu	:= GetArea()
	Local aAreaPAE	:= PAE->( GetArea() )
	Local lRetorno	:= .F.
	Local cCCOri	:= CriaVar( "C7_CC", .F. )
	Local cItem		:= CriaVar( "C7_ITEM", .F. )
	Local cGrupo	:= CriaVar( "B1_GRUPO", .F. )
	Local cCodPro	:= CriaVar( "B1_COD", .F. )
	Local cNumCot	:= CriaVar( "C7_NUMCOT", .F. )
	Local cOrigem	:= AllTrim( FunName() )
	Local cQry		:= ""
	
	Default cCCusto	:= &( ReadVar() )
	//�����������������������������������������������������������������������������������������Ŀ
	//� Obtem as vari�veis para valida��o de acordo com a origem da chamada da fun��o           �
	//�������������������������������������������������������������������������������������������
	If "MATA120" $ cOrigem .Or. "MATA121" $ cOrigem
		cCCOri	:= aCols[n, aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_CC" } )]
		cItem	:= aCols[n, aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_ITEM" } )]
		cCodPro	:= aCols[n, aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_PRODUTO" } )]
		cGrupo	:= GetAdvFVal( "SB1", "B1_GRUPO", xFilial( "SB1" ) + cCodPro, 1, "" )
		cNumCot	:= GetAdvFVal( "SC7", "C7_NUMCOT", xFilial( "SC7" ) + cA120Num + cItem, 1, "" )
	ElseIf "MATA110" $ cOrigem
		cCCOri	:= aCols[n, aScan( aHeader, { |x| AllTrim( x[2] ) == "C1_CC" } )]
		cItem	:= aCols[n, aScan( aHeader, { |x| AllTrim( x[2] ) == "C1_ITEM" } )]
		cCodPro	:= aCols[n, aScan( aHeader, { |x| AllTrim( x[2] ) == "C1_PRODUTO" } )]
		cGrupo	:= GetAdvFVal( "SB1", "B1_GRUPO", xFilial( "SB1" ) + cCodPro, 1, "" )
		cNumCot	:= CriaVar( "C7_NUMCOT", .F. )
	EndIf
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Pesquisa no PAA se existe a amarra��o usu�rio x centro de custo                         �
	//�������������������������������������������������������������������������������������������
	dbSelectArea( "PAE" )
	dbSetOrder( 1 )
	MsSeek( xFilial( "PAE" ) + __cUserId )
	While !Eof() .And. PAE->PAE_FILIAL == xFilial( "PAE" ) .And. ;
		PAE->PAE_CODUSR == __cUserId
		//�������������������������������������������������������������������������������������Ŀ
		//� Valida se o centro de custo informada esta dentro dos par�metros da linha           �
		//���������������������������������������������������������������������������������������
		If cCCusto >= PAE->PAE_CCINI .And. cCCusto <= PAE->PAE_CCFIM .And.;
			cGrupo >= PAE->PAE_GRPINI .And. cGrupo <= PAE->PAE_GRPFIM
			lRetorno	:= .T.
		EndIf
		dbSkip()
	EndDo
	
	If !lRetorno
		Aviso(	"MT120LOK-18",;
		"O centro de custo informado n�o esta autorizado para o usu�rio." + Chr(13) + Chr(10) +;
		"Selecione um centro de custo v�lido para o usu�rio.",;
		{ "&Retorna" }, 2,;
		"Centro de Custo: " + cCCusto )
	EndIf
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� N�o permitir altera��o do centro de custo quando existir n�mero de cota��o              �
	//�������������������������������������������������������������������������������������������
	If lRetorno .And. !Empty( cNumCot ) .And. cCCOri <> cCCusto
		Aviso(	"MT120LOK-19",;
		"O pedido foi gerado atrav�s de uma cota��o e n�o pode ter o seu centro de custo alterado.",;
		{ "&Retorna" }, 2,;
		"N�mero da Cota��o: " + cNumCot )
		lRetorno	:= .F.
	EndIf
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Restaura as �reas originais                                                             �
	//�������������������������������������������������������������������������������������������
	RestArea( aAreaPAE )
	RestArea( aAreaAtu )

Return( lRetorno )

/*/{Protheus.doc} User Function VLDUSR2GR
	Funcao para validar se o usuario esta autorizado a associar o grupo do produto
	@type  Function
	@author Almir Bandina
	@since 05/03/2008
	@version 01
	@history 
/*/
User Function VldUsr2Gr()

	//�����������������������������������������������������������������������������������������Ŀ
	//� Define as vari�veis utilizadas na rotina                                                �
	//�������������������������������������������������������������������������������������������
	Local aAreaAtu	:= GetArea()
	Local aAreaPAE	:= PAE->( GetArea() )
	Local lRetorno	:= .F.
	Local cCampo	:= ReadVar()
	Local cCodPro	:= CriaVar( "C7_PRODUTO", .F. )
	Local cGrpPro	:= CriaVar( "BM_GRUPO", .F. )
	Local cOrigem	:= AllTrim( FunName() )
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Obtem as vari�veis para valida��o de acordo com a origem da chamada da fun��o           �
	//�������������������������������������������������������������������������������������������
	if cmodulo = "EEC" //Incluido por Adriana para desconsiderar a validacao quando pedido incluido pelo modulo EEC
		return .t.
	endif
	
	//If "MATA120" $ cOrigem .Or. "MATA121" $ cOrigem   // retirado em 03/02/10 por Daniel G.Jr.
	If "MATA120" $ cOrigem .Or. "MATA121" $ cOrigem .Or. "MATA122" $ cOrigem	// inclu�do em 03/02/10 por Daniel G.Jr.
		cCodPro	:= aCols[n, aScan( aHeader, { |x| AllTrim( x[2] ) == "C7_PRODUTO" } ) ]
		//�������������������������������������������������������������������������������������Ŀ
		//� Obtem o produto digitado quando estiver no campo de c�digo do produto               �
		//���������������������������������������������������������������������������������������
		If "C7_PRODUTO" $ cCampo
			cCodPro	:= &( ReadVar() )
		EndIf
	ElseIf "MATA110" $ cOrigem
		cCodPro	:= aCols[n, aScan( aHeader, { |x| AllTrim( x[2] ) == "C1_PRODUTO" } ) ]
		//�������������������������������������������������������������������������������������Ŀ
		//� Obtem o produto digitado quando estiver no campo de c�digo do produto               �
		//���������������������������������������������������������������������������������������
		If "C1_PRODUTO" $ cCampo
			cCodPro	:= &( ReadVar() )
		EndIf
	EndIf
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Obtem o grupo para o produto                                                            �
	//�������������������������������������������������������������������������������������������
	cGrpPro	:= GetAdvFVal( "SB1", "B1_GRUPO", xFilial( "SB1" ) + cCodPro, 1, "" )
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Pesquisa no PAA se existe a amarra��o usu�rio x centro de custo                         �
	//�������������������������������������������������������������������������������������������
	dbSelectArea( "PAE" )
	dbSetOrder( 1 )
	MsSeek( xFilial( "PAE" ) + __cUserId )
	While !Eof() .And. PAE->PAE_FILIAL == xFilial( "PAE" ) .And. ;
		PAE->PAE_CODUSR == __cUserId
		
		//�������������������������������������������������������������������������������������Ŀ
		//� Valida se o centro de custo informada esta dentro dos par�metros da linha           �
		//���������������������������������������������������������������������������������������
		If cGrpPro >= PAE->PAE_GRPINI .And. cGrpPro <= PAE->PAE_GRPFIM
			lRetorno	:= .T.
		EndIf
		
		dbSkip()
	EndDo
	
	If !lRetorno
		Aviso(	"MT120LOK-20",;
		"O grupo para o produto informado n�o esta autorizado para o usu�rio." + Chr(13) + Chr(10) +;
		"Selecione um produto com grupo v�lido para o usu�rio.",;
		{ "&Retorna" }, 2,;
		"Produto/Grupo: " + AllTrim( cCodPro ) + "/" + CGrpPro )
	EndIf
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Restaura as �reas originais                                                             �
	//�������������������������������������������������������������������������������������������
	RestArea( aAreaPAE )
	RestArea( aAreaAtu )

Return( lRetorno )

/*/{Protheus.doc} User Function VLDUSR2IT
	Funcao para validar se o usuario esta autorizado a associar o item contabil
	@type  Function
	@author Almir Bandina
	@since 05/03/2008
	@version 01
	@history 
/*/
User Function VldUsr2IT( cItemCta )

	//�����������������������������������������������������������������������������������������Ŀ
	//� Define as vari�veis utilizadas na rotina                                                �
	//�������������������������������������������������������������������������������������������
	Local aAreaAtu	:= GetArea()
	Local aAreaPAE	:= PAE->( GetArea() )
	Local lRetorno	:= .F.
	Local cGrupo	:= CriaVar( "B1_GRUPO", .F. )
	Local cCodPro	:= CriaVar( "B1_COD", .F. )
	Local cCodPro	:= aCols[n, aScan( aHeader, { |x| AllTrim( x[2] ) == IIF(FUNNAME() == "MATA110","C1_PRODUTO","C7_PRODUTO")})]
	Local cGrupo	:= GetAdvFVal( "SB1", "B1_GRUPO", xFilial( "SB1" ) + cCodPro, 1, "" )
	
	Default cItemCta:= &( ReadVar() )
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Pesquisa no PAA se existe a amarra��o usu�rio x centro de custo                         �
	//�������������������������������������������������������������������������������������������
	dbSelectArea( "PAE" )
	dbSetOrder( 1 )
	MsSeek( xFilial( "PAE" ) + __cUserId )
	While !Eof() .And. PAE->PAE_FILIAL == xFilial( "PAE" ) .And. ;
		PAE->PAE_CODUSR == __cUserId
		
		//�������������������������������������������������������������������������������������Ŀ
		//� Valida se o centro de custo informada esta dentro dos par�metros da linha           �
		//���������������������������������������������������������������������������������������
		If cItemCta >= PAE->PAE_ITINI .And. cItemCta <= PAE->PAE_ITFIM .And.;
			cGrupo >= PAE->PAE_GRPINI .And. cGrupo <= PAE->PAE_GRPFIM
			lRetorno	:= .T.
		EndIf
		
		dbSkip()
	EndDo
	
	If !lRetorno
		Aviso(	"MT120LOK-21",;
		"O item cont�bil informado n�o esta autorizado para o usu�rio." + Chr(13) + Chr(10) +;
		"Selecione um item cont�bil v�lido para o usu�rio.",;
		{ "&Retorna" }, 2,;
		"Item Cont�bil: " + cItemCta )
	EndIf
	
	//�����������������������������������������������������������������������������������������Ŀ
	//� Restaura as �reas originais                                                             �
	//�������������������������������������������������������������������������������������������
	RestArea( aAreaPAE )
	RestArea( aAreaAtu )
	
Return( lRetorno )

/*/{Protheus.doc} Static Function CHKZCN
	Consiste lote recria RNX2
	@type  Function
	@author Fernando Macieira
	@since 19/03/2019
	@version 01
	@history 
/*/
Static Function ChkZCN()

	Local lRet     := .t.
	Local cEmpZCN  := GetMV("MV_#ZCNEMP",,"07")
	Local aAreaZCN := ZCN->( GetArea() )
	Local cLoteZCN := ""
	Local cCC      := ""

	Local aAreaSC1 := SC1->( GetArea() )
	Local cNumSC   := ""
	Local cItemSC  := ""

	// Empresas autorizadas
	If cEmpAnt $ cEmpZCN
	
		cCC := gdFieldGet("C7_CC", n)

		// Busca Lote recria da SC se nao foi informado
		cLoteZCN := gdFieldGet("C7_XLOTECC", n)
		If Empty(cLoteZCN)
			cNumSC  := gdFieldGet("C7_NUMSC", n)
			cItemSC := gdFieldGet("C7_ITEMSC", n)
	
			SC1->( dbSetOrder(1) ) // C1_FILIAL + C1_NUM + C1_ITEM
			If SC1->( dbSeek( FWxFilial("SC1")+cNumSC+cItemSC ) )
				gdFieldPut("C7_XLOTECC", SC1->C1_XLOTECC, n)
				gdFieldPut("C7_XDLOTCC", SC1->C1_XDLOTCC, n)
			EndIf
	    EndIf
		
		// Lote Recria informado
		cLoteZCN := gdFieldGet("C7_XLOTECC", n)
		If !Empty(cLoteZCN)

			ZCN->( dbSetOrder(1) ) // ZCN_FILIAL+ZCN_LOTE                                                                                                                                             
			If ZCN->( dbSeek( FWxFilial("ZCN")+cLoteZCN ) )
			
				// Consisto lote encerrado
				If AllTrim(ZCN->ZCN_STATUS) == "E" 
					lRet := .f.
					Alert("[MT120LOK-ZCN1] - Lote Recria com status Encerrado! Contate a contabilidade...")
				EndIf
				
				// Consisto CC informado
				If lRet
					If AllTrim(cCC) <> AllTrim(ZCN->ZCN_CENTRO)
					  lRet := .f.
					  Alert("[MT120LOK-ZCN2] - Lote Recria n�o amarrado com o Centro de Custo informado! Contate a contabilidade...")
					EndIf
				EndIf
				
			Else
			
				// Lote informado nao cadastrado na ZCN
				lRet := .f.
				Alert("[MT120LOK-ZCN3] - Lote Recria n�o cadastrado! Contate a contabilidade...")

			EndIf

		EndIf
		
		// Chamado n. 048414 || OS 049698 || CONTROLADORIA || ANDRESSA || 45968437 || NOTAS -LOTE RNX2 - FWNM - 10/04/2019
		// CC informado
		If lRet
			If !Empty(cCC)

				ZCN->( dbSetOrder(2) ) // ZCN_FILIAL+ZCN_DESCLT
				If ZCN->( dbSeek( FWxFilial("ZCN")+cCC ) )
				
					If Empty(cLoteZCN)
						lRet := .f.  
						Alert("[MT120LOK-ZCN4] - Centro de Custo informado possui Lote Recria amarrado! Informe o Lote Recria ou contate a contabilidade...")
					EndIf
		
				EndIf
	
			EndIf
		EndIf
		//
	
	EndIf
	
	RestArea( aAreaZCN )
	RestArea( aAreaSC1 )

Return lRet

/*/{Protheus.doc} User Function UPSM2
	Moedas estrangeiras para projetos de investimentos
	@type  Function
	@author Fernando Macieira
	@since 21/10/2019
	@version 01
	@history 
/*/
Static Function UpSM2()

	Local nTaxa    := 0
	Local aAreaSM2 := SM2->( GetArea() )
	
	SM2->( dbSetOrder(1) ) // M2_DATA                                                                                                                                                         
	If SM2->( dbSeek(da120emis) )

		If nMoedaPed == 2
			nTaxa := SM2->M2_MOEDA2
		
		ElseIf nMoedaPed == 3
			nTaxa := SM2->M2_MOEDA3

		ElseIf nMoedaPed == 4
			nTaxa := SM2->M2_MOEDA4

		ElseIf nMoedaPed == 5
			nTaxa := SM2->M2_MOEDA5

		EndIf
		
	EndIf
	
	RestArea( aAreaSM2 )

Return nTaxa

/*/{Protheus.doc} User Function C7OP
	Fun��o utilizada nos gabilhos dos campos (C7_QUANT, seq 004)
	Sintaxe: If(FindFunction("U_C7OP"),u_C7OP(),Space(TamSX3("C7_OP")[1]))
	@type  Function
	@author Fernando Macieira
	@since 08/02/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 8582 - Fernando Macieira - 08/02/2021 - Replicar OP na pr�xima linha
/*/
User Function C7OP()

	Local cOP  := ""
	Local nAux := 0

	If !ALTERA

		nAux := n-1
		If nAux < 1
			nAux := 1
		Else
			nAux := n-1
		EndIf

		If !gdDeleted(n) .and. !Empty( gdFieldGet("C7_OP", nAux) )
			cOP := gdFieldGet("C7_OP", nAux)
		EndIf

		If !Empty(cOP)
			gdFieldPut("C7_OP", cOP, n)
		EndIf

	EndIf
	//

Return cOP

/*/{Protheus.doc} Static Function ChkCCOP
	Realizar trava no CC 5304 - sempre ter que preencher o campo OP
	@type  Function
	@author user
	@since 08/03/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	ticket 10573 - Fernando Macieira - 08/03/2021 - Ponto de Corre��o - Manuten��o de Ativos
/*/
Static Function ChkCCOP()

	Local lRet    := .t.
	Local cCC5304 := GetMV("MV_#MNTCC",,"5304")
	Local cOP     := ""
	Local cCC     := ""

	cCC := gdFieldGet("C7_CC", n)
	cOP := gdFieldGet("C7_OP", n)

	If AllTrim(cCC) $ AllTrim(cCC5304)

		If Empty(cOP)
			
			lRet := .f.
			Alert("[MT120LOK-CCOP] - Obrigat�rio o preenchimento da OP para estes centro de custo ( " + cCC5304 + " ), conforme exig�ncia departamento de manuten��o." )

		EndIf

	EndIf

Return lRet
