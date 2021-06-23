#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"

/*/{Protheus.doc} User Function MT110LOK
	Ponto de Entrada para validar a existência de centro de custos
	e item contábil.
	@type  Function
	@author Fábrica Tradicional
	@since 17/07/2008
	@version 01
	@history 06.07.09 - Mauricio HC - Chamado 004603 de obrigar preenchimento do campo Projeto quando C.Custo iniciado por 9.
	@history 08/01/19 - FWNM - Chamado n. 046284 - Novas regras alteracao valor
	@history 047931 || OS 049195 || CONTROLADORIA || ANDRESSA || 45968437 || C.CUSTO X LOTE -RNX2 - FWNM - 19/03/2019
	@history 048414 || OS 049698 || CONTROLADORIA || ANDRESSA || 45968437 || NOTAS -LOTE RNX2 - FWNM - 10/04/2019
	@history Everson, 04/11/2020, Chamado 2562. Validação de estudo de projeto vinculado à solicitação de compra.
	@history ticket  8582 - Fernando Macieira - 08/02/2021 - Replicar OP na próxima linha
	@history ticket 10573 - Fernando Macieira - 08/03/2021 - Ponto de Correção - Manutenção de Ativos
/*/
User Function MT110LOK()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as variáveis utilizadas na rotina                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aAreaAtu1	:= GetArea()
	Local lRetorno	:= .T.
	Local aAprov	:= {}
	Local nLoop		:= 0
	Local nPConta	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C1_CONTA" } )
	Local nPCusto	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C1_CC" } )
	Local nPItemCta	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C1_ITEMCTA" } )
	Local nPClasse	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C1_CLVL" } )
	Local nPProduto	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C1_PRODUTO" } )
	Local nPProjeto	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C1_PROJADO" } )
	Local nPCodProj	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "C1_CODPROJ" } )
	Local nTotal	:= 0
	Local cConta	:= aCols[n,nPConta]
	Local cCusto	:= aCols[n,nPCusto]
	Local cItemCta	:= aCols[n,nPItemCta]
	Local cClasse	:= aCols[n,nPClasse]
	Local cProjeto	:= aCols[n,nPProjeto]
	Local cProduto	:= aCols[n,nPProduto]
	Local cCodProj	:= aCols[n,nPCodProj]
	
	// FWNM - 16/02/2018 - Projetos Investimentos
	Local lSldAtv  := GetMV("MV_#PRJSLD",,".T.")
	Local cFasePrj := GetMV("MV_PRJINIC",,"05")
	
	// Chamado n. 046284
	Local cFaseRej := GetMV("MV_#FASREJ",,"01")
	Local cFaseApr := GetMV("MV_#FASEOK",,"03")
	//  

	//Everson - 04/11/2020. Chamado 2562.
	Local cEstPrj  := Alltrim(cValToChar(aCols[n, aScan( aHeader, { |x| AllTrim( x[2] ) == "C1_XITEMST" } ) ]))
	//

	// @history ticket 8582 - Fernando Macieira - 08/02/2021 - Replicar OP na próxima linha
	Local cOp  := "" 
	Local nAux := 0
	//
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se deixou o centro de custo em branco não permite inclusão                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. Empty( cCusto )
		Aviso(	"MT110LOK-01",;
		"É obrigatório o preenchimento do Centro de Custo.",;
		{ "&Retorna" },,;
		"Conteúdo em Branco" )
		lRetorno	:= .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se deixou o item contábil em branco não permite inclusão                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. Empty( cItemCta )
		Aviso(	"MT110LOK-02",;
		"É obrigatório o preenchimento do Item Contábil.",;
		{ "&Retorna" },,;
		"Conteúdo em Branco" )
		lRetorno	:= .F.
	EndIf 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obriga informar a classe de valor se a conta iniciar por 31 e o centro de custo por 6   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SubStr( cConta, 1, 2 ) == "31" .And. SubStr ( cCusto, 1, 1 ) == "6" .And. Empty( SubStr( cClasse, 1, 1 ) )
		Aviso(	"MT110LOK-03",;
		"Conta Contábil: " + AllTrim( cConta ) + " Centro de Custo: " + cCusto + "." + Chr(13) + Chr(10) +;
		"É obrigatório o preenchimento da Classe de Valor.",;
		{ "&Retorna" },,;
		"Conteúdo em Branco" )
		lRetorno	:= .F.
		//MSGSTOP( "Obrigatorio preenchimento da Classe de Valor", "ATENÇÃO", "ALERT")
		//_lRet := .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obriga informar o projeto se o centro de custo iniciar por 9                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SubStr( cCusto, 1, 1) == "9" .And. Empty( cProjeto )
		Aviso(	"MT110LOK-04",;
		"Centro de Custo: " + cCusto + "." + Chr(13) + Chr(10) +;
		"É obrigatório o preenchimento do Projeto.",;
		{ "&Retorna" },,;
		"Conteúdo em Branco" )
		lRetorno	:= .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o centro de custo nao iniciar por 9 nao pode haver codigo do projeto.Mauricio -Chamado 007547³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cProjeto) .And. SubStr( cCusto, 1, 1) <> "9"
		Aviso(	"MT110LOK-05",;
		"Centro de Custo: " + cCusto + "." + Chr(13) + Chr(10) +;
		"Nao pode ter o campo projeto preenchido.",;
		{ "&Retorna" },,;
		"Conteúdo em Branco" )
		lRetorno	:= .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz verificacao se o projeto se encontra encerrado ou nao para aceitar lancamento       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("AF8")
	DbSetOrder(1)
	if dbseek(xFilial("AF8")+cProjeto)
		if AF8->AF8_ENCPRJ == "1"
			Aviso(	"MT110LOK-06",;
			"Projeto: " + cProjeto + "." + Chr(13) + Chr(10) +;
			"Projeto ja se encontra encerrado. Deve ser utilizado outro projeto",;
			{ "&Retorna" },,;
			"Conteúdo em Branco" )
			lRetorno	:= .F.
		endif
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obriga informar o codigo do projeto se o campo Projeto estiver preenchido               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cEmpAnt == "01"
		If !Empty( cProjeto ) .And. Empty(cCodProj)
			Aviso(	"MT110LOK-09",;
			"Projeto: " + cProjeto + "." + Chr(13) + Chr(10) +;
			"É obrigatório o preenchimento do Codigo do Projeto.",;
			{ "&Retorna" },,;
			"Conteúdo em Branco" )
			lRetorno	:= .F.
		ElseIf Empty( cProjeto ) .And. !Empty(cCodProj)
			aCols[n,aScan(aHeader,{|x| AllTrim(x[2]) == "C1_CODPROJ"})] := "   "
		EndIf
	Endif
	
	// Projetos - FWNM - 16/02/2018
	If lRetorno
		
		If !gdDeleted(n)
			
			cPrj   := gdFieldGet("C1_PROJADO", n)
			cCC    := gdFieldGet("C1_CC", n)
			
			dDtDig := msDate()
			
			
			// Consiste exigência ou não do projeto
			lPrjInv := Left(AllTrim(cCC),1) == "9"
			
			// qdo prj investimento
			If lPrjInv .and. !Alltrim(cCC) $ GetMV("MV_#CCPADR")
				
				If Empty(cPrj)
					lRetorno := .f.
					
					Aviso(	"MT110LOK-07",;
					"Centro de Custo: " + cCC + "." + Chr(13) + Chr(10) +;
					"É obrigatório o preenchimento do Projeto.",;
					{ "&Retorna" },,;
					"Conteúdo em Branco" )
				EndIf
				
				
				// Consiste CC permitidos para aquele projeto (ZC1)
				If lRetorno
					
					ZC1->( dbSetOrder(1) ) // ZC1_FILIAL+ZC1_PROJET+ZC1_CC
					If ZC1->( !dbSeek(xFilial("ZC1")+cPrj+cCC) )
						
						lRetorno := .f.
						
						Aviso(	"MT110LOK-11",;
						"Centro Custo não permitido para este projeto! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
						"CC: " + cCC + " - " + Posicione("CTT",1,xFilial("CTT")+cCC,"CTT_DESC01") + chr(13) + chr(10) +;
						"Projeto: " + cPrj + " - " + AF8->AF8_DESCRI,;
						{ "&Retorna" },,;
						"Projeto x CC permitidos" )
						
					EndIf
					
				EndIf
				
				
				// Consiste filial/planta permitida para aquele CC
				If lRetorno
					
					If Left(AllTrim(cPrj),2) <> cFilAnt
						
						lRetorno := .f.
						
						Aviso(	"MT110LOK-12",;
						"Este projeto n. " + AllTrim(cPrj) + " não pertence a esta filial! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
						"Filial/Planta: " + cFilAnt + chr(13) + chr(10) +;
						"Projeto/Planta: " + Left(AllTrim(cPrj),2),;
						{ "&Retorna" },,;
						"Projeto x Filial/Planta" )
						
					EndIf
					
				EndIf
				
				
				// consisto valor/saldo, fase e vigencia do prj
				If lRetorno
					
					If !Empty(cPrj)
						
						AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
						If AF8->( dbSeek(xFilial("AF8")+cPrj) )
							
							// Consistencia do projeto
							If lSldAtv
								
								// Consiste apenas projetos que possuem valor
								If AF8->AF8_XVALOR > 0
									
									
									// Consiste fase do projeto para checar se esta na central de aprovacao
									//If AllTrim(cFasePrj) == AllTrim(AF8->AF8_FASE) // Chamado n. 046284
									If AllTrim(AF8->AF8_FASE) <> AllTrim(cFaseApr) // Se fase diferente de aprovada // Chamado n. 046284
										
										lRetorno := .f.
										
										Aviso(	"MT110LOK-09",;
										"Projeto n. " + AllTrim(cPrj) + " não foi aprovado na Central de Aprovação! " + chr(13) + chr(10) + "Uso ainda não permitido..." + chr(13) + chr(10) + ;
										"",;
										{ "&Retorna" },,;
										"Projeto não aprovado" )
										
									EndIf
									
									
									// Consiste datas previstas do projeto (AF8) x data de digitação oriunda do servidor do documento
									If lRetorno
										
										If dDtDig < AF8->AF8_START .or. dDtDig > AF8->AF8_FINISH
											
											lRetorno := .f.
											
											Aviso(	"MT110LOK-10",;
											"Vigência do projeto n. " + AllTrim(cPrj) + " está fora! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
											"Data Digitação: " + DtoC(dDtDig) + chr(13) + chr(10) +;
											"Início-Fim Projeto: " + DtoC(AF8->AF8_START) + " - " + DtoC(AF8->AF8_FINISH),;
											{ "&Retorna" },,;
											"Vigência do Projeto" )
											
										EndIf
										
									EndIf
									
								EndIf
								
							EndIf
							
						EndIf
						
					EndIf
					
				EndIf
				
			Else
				
				If !Empty(cPrj)
					lRetorno := .f.
					
					Aviso(	"MT110LOK-08",;
					"Centro de Custo: " + cCC + "." + Chr(13) + Chr(10) +;
					"Não permitido o preenchimento do Projeto.",;
					{ "&Retorna" },,;
					"Não permitido informar projeto para CC que não é investimento" )
				EndIf
				
			EndIf
			
		EndIf
		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se todos os itens tem o mesmo grupo de aprovação em função do centro de custo  ³
	//³ e item contábil                                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Só valida se houver mais de um elemento no aCols                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len( aCols ) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obtem a estrutura de aprovação do centro de custo da linha posicionada          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAprov	:= U_GetAprov( cCusto, cItemCta, nTotal, cProduto )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se não encontrar aprovador, não deixa colocar o pedido                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len( aAprov ) == 0
				Aviso(	"MT110LOK-13",;
				"Não foi localizado controle de alçada para o centro de custo/Item Contábil.",;
				{ "&Retorna" },,;
				"C.Custo/Item: " + cCusto + "/" + cItemCta )
				lRetorno	:= .F.
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Varre todo o array para validação                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nLoop := 1 To Len( aCols )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Só valida se não for a linha posicionada                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !( aCols[nLoop,Len( aHeader ) + 1] ) .And. nLoop <> n
						lRetorno	:= VldCCusto( aCols[nLoop,nPCusto], cCusto, aCols[nLoop,nPItemCta], cItemCta, aAprov )
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se teve erro na validação aborta retornando inválido                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lRetorno
						Exit
					EndIf
				Next nLoop
			EndIf
		EndIf
	EndIf

	//Everson - 04/11/2020. Chamado 2562.
	//Valida se há item de estudo atrelado ao projeto.
	If lRetorno .And. ! Empty( cProjeto ) .And. Empty( cEstPrj )

		//
		If Upper(Alltrim(cValToChar(Posicione("AF8",1, FWxFilial("AF8") + cProjeto,"AF8_XESTUD")))) == "S"
			Aviso(	"MT110LOK-15",;
			"Projeto: " + cProjeto + "." + Chr(13) + Chr(10) +;
			"É obrigatório o preenchimento do código do estudo do projeto.",;
			{ "&Retorna" },,;
			"Conteúdo em Branco" )
			lRetorno	:= .F.

		EndIf 

	EndIf
	//

	// Chamado n. 047931 || OS 049195 || CONTROLADORIA || ANDRESSA || 45968437 || C.CUSTO X LOTE -RNX2 - FWNM - 19/03/2019
	If lRetorno
		lRetorno := ChkZCN()
	EndIf
	// 

	//@history ticket 10573 - Fernando Macieira - 08/03/2021 - Ponto de Correção - Manutenção de Ativos
	If lRetorno
		lRetorno := ChkCCOP()
	EndIf
	//

	restarea(aAreaAtu1)

Return( lRetorno )

/*/{Protheus.doc} VldCCusto
	Função para validar se o centro de custo digitado tem a mesma
	estrutura de aprovação dos demias centros de custos.	
	@type  Static Function
	@author Almir Bandina
	@since 
	@version 01
	/*/
Static Function VldCCusto( cCCLinha, cCCOrig, cItLinha, cItOrig, aAprov )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as variáveis utilizadas na rotina                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aAux		:= U_GetAprov( cCCLinha, cItLinha )
	Local lRetorno	:= .T.
	Local nLoop		:= 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Varre o array auxiliar e procura no array de aprovadores se existe                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nLoop := 1 To Len( aAux )
		If aScan( aAprov, { |x| x[1] == aAux[nLoop,01] } ) == 0
			lRetorno	:= .F.
			Exit
		EndIf
	Next nLoop
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a interface com o usuário da divergência de estrutura de aprovação                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lRetorno
		Aviso(	"MT110LOK-14",;
		"Existem aprovadores diferentes para o centro de custo/Item Contábil informado." + Chr(13) + Chr(10) +;
		"Selecione um centro de custo/Item Contábil com a mesma estrutura de aprovação.",;
		{ "&Retorna" }, 2,;
		"Centro de Custo/Item: " + cCCOrig + "/" + cItOrig )
	EndIf

Return( lRetorno )

/*/{Protheus.doc} ChkZCN
	@type  Static Function
	@author Microsiga
	@since 03/19/2019
	@version 01
/*/
Static Function ChkZCN()

	Local lRet     := .t.
	Local cEmpZCN  := GetMV("MV_#ZCNEMP",,"07")
	Local aAreaZCN := ZCN->( GetArea() )
	Local cLoteZCN := ""
	Local cCC      := ""

	// Empresas autorizadas
	If cEmpAnt $ cEmpZCN
	
		cCC      := gdFieldGet("C1_CC", n)
		cLoteZCN := gdFieldGet("C1_XLOTECC", n)

		// Lote Recria informado
		If !Empty(cLoteZCN)

			ZCN->( dbSetOrder(1) ) // ZCN_FILIAL+ZCN_LOTE                                                                                                                                             
			If ZCN->( dbSeek( FWxFilial("ZCN")+cLoteZCN ) )
			
				// Consisto lote encerrado
				If AllTrim(ZCN->ZCN_STATUS) == "E" 
					lRet := .f.
					Alert("[MT110LOK-ZCN1] - Lote Recria com status Encerrado! Contate a contabilidade...")
				EndIf
				
				// Consisto CC informado
				If lRet
					If AllTrim(cCC) <> AllTrim(ZCN->ZCN_CENTRO)
					  lRet := .f.
					  Alert("[MT110LOK-ZCN2] - Lote Recria não amarrado com o Centro de Custo informado! Contate a contabilidade...")
					EndIf
				EndIf
				
			Else
			
				// Lote informado nao cadastrado na ZCN
				lRet := .f.
				Alert("[MT110LOK-ZCN3] - Lote Recria não cadastrado! Contate a contabilidade...")

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
						Alert("[MT110LOK-ZCN4] - Centro de Custo informado possui Lote Recria amarrado! Informe o Lote Recria ou contate a contabilidade...")
					EndIf
		
				EndIf
	
			EndIf
		EndIf
		//

	EndIf
	
	RestArea( aAreaZCN )

Return lRet

/*/{Protheus.doc} User Function C1OP
	Função utilizada nos gabilhos dos campos (C1_QUANT, seq 002)
	Sintaxe: If(FindFunction("U_C1OP"),u_C1OP(),Space(TamSX3("C1_OP")[1]))
	@type  Function
	@author Fernando Macieira
	@since 08/02/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 8582 - Fernando Macieira - 08/02/2021 - Replicar OP na próxima linha
/*/
User Function C1OP()

	Local cOP  := ""
	Local nAux := 0

	If !ALTERA

		nAux := n-1
		If nAux < 1
			nAux := 1
		Else
			nAux := n-1
		EndIf

		If !gdDeleted(n) .and. !Empty( gdFieldGet("C1_OP", nAux) )
			cOP := gdFieldGet("C1_OP", nAux)
		EndIf

		If !Empty(cOP)
			gdFieldPut("C1_OP", cOP, n)
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
	ticket 10573 - Fernando Macieira - 08/03/2021 - Ponto de Correção - Manutenção de Ativos
/*/
Static Function ChkCCOP()

	Local lRet    := .t.
	Local cCC5304 := GetMV("MV_#MNTCC",,"5304")
	Local cOP     := ""
	Local cCC     := ""

	cCC := gdFieldGet("C1_CC", n)
	cOP := gdFieldGet("C1_OP", n)

	If AllTrim(cCC) $ AllTrim(cCC5304)

		If Empty(cOP)
			
			lRet := .f.
			Alert("[MT110LOK-CCOP] - Obrigatório o preenchimento da OP para estes centro de custo ( " + cCC5304 + " ), conforme exigência departamento de manutenção." )

		EndIf

	EndIf

Return lRet
