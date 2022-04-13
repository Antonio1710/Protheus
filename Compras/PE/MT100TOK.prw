#INCLUDE "rwmake.ch"
#Include "Topconn.ch"
#INCLUDE "Protheus.ch"

/*/{Protheus.doc} User Function MT100TOK
    Ponto Entrada na inclusao do documento de entrada
    Carrega variavel publica __MTCOLSE2 para ser utilizada no PE MT100TOK
    @type  Function
    @author Mauricio da Silva
    @since 08/02/2011
    @version version
    @history Chamado 047942 - FWNM            - 19/03/2019 - 047942 || OS 049210 || FISCAL || SIMONE || 8463 ||C.C 8011 (PC X D.E) 
    @history Chamado TI     - Everson         - 09/05/2019 - Validacao data de emissao
    @history Chamado TI     - Everson         - 10/05/2019 - Validacao especie doc
    @history Chamado TI     - Abel Babini     - 11/06/2019 - Excluir NF de Compl da Validacao
    @history Chamado 044314 - Everson         - 19/07/2019 - Tratamento inclusao CT-e pela rotina ADFIS032P
    @history Chamado 050109 - Abel Babini     - 05/08/2019 - Tratamento inclusao NF manual saida (Complemento ICMS)
    @history Chamado 053639 - FWNM            - 26/11/2019 - 053639 || OS 055007 || FISCAL || DEJAIME || 8921 || ENTRADA X DUPLICATAS
    @history Chamado TI     - FWNM            - 10/12/2019 - Tratamento error log na execucao das integrações SAG
    @history Chamado TI     - FWNM            - 10/12/2019 - Tratamento consistencia notas sem PC
    @history Chamado TI     - FWNM            - 10/12/2019 - Tratamento consistencia CTE e outros casos
	@history Chamado 053639 - FWNM            - 28/01/2020 - OS 056753 || FISCAL || DEJAIME || 8921 || VAL. NF X DUPLICATA
    @history Chamado 056841 - Abel Babini     - 23/03/2020 - OS 058286 || FISCAL || ELIZABETE || 8954 || NF -  PRODUTOR RURAL || Descontar o valor do SENAR
	@history Chamado 057002 - FWNM	          - 31/03/2020 - || OS 058479 || CONTROLADORIA || MONIK_MACEDO || 996108893 || CONTABILIZACAO
	@history chamado 057107 - FWNM 		      - 03/04/2020 - || OS 058613 || CONTROLADORIA || TAMIRES_SERAFIM || 8503 || CONTA CONTABEIS
	@history chamado 058358 - WILLIAM COSTA   - 02/06/2020 - Feito a trava no sistema que busca todos os centro de custos dos itens da nota e compara com o centro de custos do pedido de compra quando eles estão diferentes o Centro de Custo da Nota com o Centro de Custo do Pedido de Compra, o sistema trava mostrando uma mensagem de erro e não deixa salvar a nota
	@history Ticket 10404   - ADRIANO SAVOINE - 05/03/2021 - Ajuste no IF para desconsiderar os pedidos de compra que tiverem TES no parametro MV_TESPCNF.
	@history Chamado 8566 	- André Mendes 	  - 29/04/2021 - Transferência entre Filiais
	@history ticket  6652   - Fernan Macieira - 18/01/2021 - Projeto 0022003001 - Revitalização Posto de Combustível, o pedido 401511 consumiu o valor do projeto e o fiscal não esta conseguindo lançar Nota fiscal  (Mensagem projeto com saldo insuficiente)
	@history ticket 14352   - Fernan Macieira - 21/05/2021 - Saldo Negativo (identificamos que a solução do ticket 6652 não foi publicada!)
	@history ticket 16401   - Fernan Macieira - 12/07/2021 - Saldo Negativo (PC com qtd parcial, porém, valor unitário muito diferente do PC e também com valor total muito próximo do PC)
	@history ticket  11639 	- Fernan Macieira - 19/05/2021 - Projeto - OPS Documento de entrada - Industrialização/Beneficiamento
	@history ticket 71057   - Fernan Macieira - 08/04/2022 - Item contábil Lançamentos da Filial 0B - Itapira
/*/
User Function MT100TOK()

	Local _aArea   := GetArea()
	Local _lRet    := .T.
	Local nCont    := 0
	Local lPadrao  := PARAMIXB[1]
	Local cChvXML  := ""
	Local nOpcVal  := 0
	Local cEspBlq  := GetMV("MV_#NFEESP",,"CTE#SPED")
	Local cEmpAut  := GetMV("MV_#NFEEMP",,"")
	Local cLogAut  := GetMV("MV_#NFEUSR",,"")
	Local cSpecLo  := "" //IIF(AllTrim(FunName()) == "MATA116",c116Especie,cEspecie)
	Local dDtLEmis := GetMV('MV_#DTEMIS') //Everson - 09/05/2019. Chamado TI.
	Local i        := 0
	Local _i       := 0
	Local nTtNF    := 0
	Local cCFOP    := 0
	Local nTt      := 0
	Local nValIpi  := 0
	Local nValFre  := 0
	Local nDespesa := 0
	Local nSeguro  := 0
	Local nICMSRet := 0
	Local nValDesc := 0
	Local nValICM  := 0
	Local nValIMP5 := 0
	Local nValIMP6 := 0
	Local nVSenar  := 0 //Chamado 056841 - Abel Babini - 23/03/2020 - OS 058286 || FISCAL || ELIZABETE || 8954 || NF -  PRODUTOR RURAL || Descontar o valor do SENAR
	Local cCondPC  := ""
	Local aParcPC  := ""
	Local aParcNF  := ""
	Local cTES     := ""
	Local lTESFin  := .f.
	Local cPC      := ""
	Local cPCItem  := ""
	Local cItemCta := ""
	Local cCCusto  := ""
	Local cCCPed   := ''
	Local cItemNot := ''
	Local cTesPcNf := SuperGetMV("MV_TESPCNF")
	Local nPosTes  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})
	Local cArm3    := ""
	Local cPCPrj := ""
	Local cPCPrjaCols := ""
	Local cPCItem := "" 

	// Chamado n. 057107 || OS 058613 || CONTROLADORIA || TAMIRES_SERAFIM || 8503 || CONTA CONTABEIS - FWNM - 03/04/2020
	For nCont :=1 To Len(aCols)
			
		If !gdDeleted(nCont)
		
			//@history ticket  6652   - Fernando Macie- 18/01/2021 - Projeto 0022003001 - Revitalização Posto de Combustível, o pedido 401511 consumiu o valor do projeto e o fiscal não esta conseguindo lançar Nota fiscal  (Mensagem projeto com saldo insuficiente)
			// Carrego pedidos de projeto de investimentos
			cPCPrjaCols := gdFieldGet("D1_PROJETO", nCont)
			If !Empty(cPCPrjaCols)
				If !(gdFieldGet("D1_PEDIDO", nCont) $ cPCPrj)
					cPCPrj += gdFieldGet("D1_PEDIDO", nCont) + ";"
				EndIf
				cPCItem += gdFieldGet("D1_PEDIDO", nCont) + gdFieldGet("D1_ITEMPC", nCont) + ";"
			EndIf
			//

			If cEmpAnt == "01" // Adoro

				If cFilAnt == "01"
					cItemCta := GetMV("MV_#ITEM01",,"121")
					gdFieldPut("D1_ITEMCTA",cItemCta,nCont)

				ElseIf cFilAnt == "02"
					cItemCta := GetMV("MV_#ITEM02",,"121")
					gdFieldPut("D1_ITEMCTA",cItemCta,nCont)

				ElseIf cFilAnt == "04"
					cItemCta := GetMV("MV_#ITEM04",,"112")
					gdFieldPut("D1_ITEMCTA",cItemCta,nCont)

				ElseIf cFilAnt == "05"
					cItemCta := GetMV("MV_#ITEM05",,"114")
					gdFieldPut("D1_ITEMCTA",cItemCta,nCont)

				ElseIf cFilAnt == "06"
					cItemCta := GetMV("MV_#ITEM06",,"122")
					gdFieldPut("D1_ITEMCTA",cItemCta,nCont)

				ElseIf cFilAnt == "08"
					cItemCta := GetMV("MV_#ITEM08",,"115")
					gdFieldPut("D1_ITEMCTA",cItemCta,nCont)

				ElseIf cFilAnt == "09"
					cItemCta := GetMV("MV_#ITEM09",,"116")
					gdFieldPut("D1_ITEMCTA",cItemCta,nCont)

				ElseIf cFilAnt == "03"
					cItemCta := GetMV("MV_#ITEM03",,"114")
					
					cCCusto  := gdFieldGet("D1_CC", nCont)
					If AllTrim(cCCusto) $ GetMV("MV_#CCFIL3",,"6910|4103|9604|9605|9606|5121")
						cItemCta := "112"
					EndIf
					If Left(AllTrim(cCCusto),1) == "7" .or. Left(AllTrim(cCCusto),2) == "97"
						cItemCta := "111"
					EndIf
					If AllTrim(cCCusto) == "5131"
						cItemCta := "113"
					EndIf

					gdFieldPut("D1_ITEMCTA", cItemCta, nCont)

				// @history ticket 71057   - Fernan Macieira - 08/04/2022 - Item contábil Lançamentos da Filial 0B - Itapira
				ElseIf AllTrim(cFilAnt) == "0B"
					cItemCta := AllTrim(GetMV("MV_#ITAFIL",,"125"))
					gdFieldPut("C1_ITEMCTA", cItemCta, nCont)
				//

				EndIf

				/////////////////////////////////
				// PROJETO INDUSTRIALIZAÇÃO 
				/////////////////////////////////
				
				// @history ticket  11639 	- Fernando Maciei - 19/05/2021 - Projeto - OPS Documento de entrada - Industrialização/Beneficiamento
				If cEmpAnt $ GetMV("MV_#BENEMP",,"01") .and. cFilAnt $ GetMV("MV_#BENFIL",,"02")

					cCFOP := AllTrim(gdFieldGet("D1_CF", nCont))
					cTES  := gdFieldGet("D1_TES", nCont)
					cProd := gdFieldGet("D1_COD", nCont)

					// Fornecedor industrializador
					cArm3 := Posicione("SA2",1,FWxFilial("SA2")+CA100FOR+CLOJA,"A2_LOCAL") // Armazém de retorno para consumo da rotina de controladoria

					If AllTrim(SA2->A2_XTIPO) == '4' // Terceiro

						// Se o armazem estiver preenchido, então operação de industrialização com fornecedores específicos
						If !Empty(cArm3)
							
							gdFieldPut("D1_LOCAL",cArm3,nCont)

							// Consisto código armazém
							NNR->( dbSetOrder(1) ) // NNR_FILIAL, NNR_CODIGO, R_E_C_N_O_, D_E_L_E_T_
							If NNR->( !dbSeek(FWxFilial("NNR")+cArm3) )
								_lRet := .f.
								Alert( "[MT100TOK-32] - CFOP de retonro Armazém de retorno de insumos não cadastrado! Verifique A2_LOCAL e NNR_CODIGO..." + chr(13) + chr(10) + ;
									"A2_LOCAL: " + cArm3 + chr(13) + chr(10) + ;
									"NNR_CODIGO: " + NNR->NNR_CODIGO )
								Return _lRet
							EndIf

						Else

							_lRet := .f.
							Alert( "[MT100TOK-31] - NF com CFOP de retorno industrialização sem armazém cadastrado! Preencha A2_LOCAL..." + chr(13) + chr(10) + ;
									"A2_LOCAL: " + cArm3 + chr(13) + chr(10) + ;
									"" )
							Return _lRet

						EndIf

						// CFOPs retorno insumos
						If cCFOP $ GetMV("MV_#BENCFO",,"1902#2902#1903#2903#1925#2925#")

							SF4->( dbSetOrder(1) ) // F4_FILIAL + F4_CODIGO
							If SF4->( dbSeek(FWxFilial("SF4")+cTES) )
								
								// Insumos tem que controlar estoque próprio e ser retorno terceiro
								If AllTrim(SF4->F4_ESTOQUE) <> "S" .or. AllTrim(SF4->F4_PODER3) <> "D"
									_lRet := .f.
									Alert( "[MT100TOK-30] - Fornecedor " + CA100FOR + ", CFOP " + cCFOP + " tem que atualizar estoque próprio e controlar retorno terceiro! Verifique..." + chr(13) + chr(10) + ;
											"TES: " + SF4->F4_CODIGO )
									Return _lRet
								EndIf

							EndIf

						EndIf

						// Exceção - Para o CFOP 1125 (pois são utilizados demais produtos que não podem poluir armazém de retorno)
						If cCFOP $ GetMV("MV_#BENCFE",,"1125#")

							SF4->( dbSetOrder(1) ) // F4_FILIAL + F4_CODIGO
							If SF4->( dbSeek(FWxFilial("SF4")+cTES) )
								
								// TES 14B = CFOP 1125 – Insumos adquiridos do Industrializador - Atualiza estoque e Não atualiza poder de terceiros
								If AllTrim(cTES) $ GetMV("MV_#BENTE1",,"14B#")

									If AllTrim(SF4->F4_ESTOQUE) <> "S" .or. AllTrim(SF4->F4_PODER3) == "D"
										_lRet := .f.
										Alert( "[MT100TOK-30] - CFOP " + cCFOP + ", TES " + cTES + " tem que atualizar estoque próprio e não controlar retorno terceiro! Verifique..." + chr(13) + chr(10) + ;
												"TES: " + SF4->F4_CODIGO )
										Return _lRet
									EndIf

								EndIf

								// TES 13U = CFOP 1125 – Serviço de Industrialização - Não atualiza estoque / Não atualiza poder de terceiros / tipo do produto deve ser SV ou MO
								If AllTrim(cTES) $ GetMV("MV_#BENTE2",,"13U#")

									If ( AllTrim(SF4->F4_ESTOQUE) <> "N" .or. AllTrim(SF4->F4_PODER3) == "D" ) .and. Posicione("SB1",1,FWxFilial("SB1")+cProd,"B1_TIPO") $ GetMV("MV_#BENPRO",,"SV#MO")
										_lRet := .f.
										Alert( "[MT100TOK-30] - CFOP " + cCFOP + ", TES " + cTES + " de produto Tipo SV/MO não pode atualizar estoque próprio e não controlar retorno terceiro! Verifique..." + chr(13) + chr(10) + ;
												"TES: " + SF4->F4_CODIGO )
										Return _lRet
									EndIf

								EndIf

							EndIf

						EndIf

					EndIf

				EndIf
				//
			
			EndIf

		EndIf
			
	Next nCont

	//@history ticket  6652   - Fernando Macie- 18/01/2021 - Projeto 0022003001 - Revitalização Posto de Combustível, o pedido 401511 consumiu o valor do projeto e o fiscal não esta conseguindo lançar Nota fiscal  (Mensagem projeto com saldo insuficiente)
	// Consisto Vlr e Qtd da NF + PC para evitar erros operacionais que podem negativar um projeto de investimento
	_lRet := ChkPrjPCNF(cPCPrj, cPCItem) //@history ticket 14352   - Fernando Macieir- 21/05/2021 - Saldo Negativo (identificamos que a solução do ticket 6652 não foi publicada!)

	If !_lRet

		Aviso( "MT100TOK-11",;
			"Lançamentos com QTD total do PC (C7_QUJE=C7_QUANT) e VALOR muito inferior! Verifique... " + chr(13) + chr(10) +;
			"MV_#PRJTOL permite tratar exceções... " + chr(13) + chr(10) + chr(13) + chr(10) +;
			"Exemplo:" + chr(13) + chr(10) +;
			"A soma das quantidades de todas as entregas encerrarão o PC, porém, a soma dos valores de todos os lançamentos não totalizarão o valor contido no PC." ,;
			{ "&OK" },,;
			"Projeto de Investimento ficará negativo no futuro após reprocessamento!" )

		Return _lRet

	EndIf
	//

	// Validar somente qdo central xml
	If IsInCallStack("U_CENTNFEXM") .or. IsInCallStack("U_RECNFEXML") .or. IsInCallStack("U_RECNFECTE") // Chamado TI - Tratamento para evitar error log nas rotinas que não carregam esta variável pública pelo PE MTCOLSE2

		If Type("__MTCOLSE2") <> "U" // Chamado TI - Tratamento para evitar error log nas rotinas que não carregam esta variável pública pelo PE MTCOLSE2

			If AllTrim(FunName()) <> "INTNFEB" // Chamado TI - Tratamento error log na execucao das integrações SAG - FWNM - 10/12/2019

				For i:=1 to Len(aCols)

					If !gdDeleted(i)

						cTES    := gdFieldGet("D1_TES", i)
						lTESFin := Posicione("SF4",1,FWxFilial("SF4")+cTES,"F4_DUPLIC") == "S"

						If lTESFin

							cCFOP    := gdFieldGet("D1_CF", i)
							nTt      := gdFieldGet("D1_TOTAL", i)
							nValIpi  := gdFieldGet("D1_VALIPI", i)
							nValFre  := gdFieldGet("D1_VALFRE", i)
							nDespesa := gdFieldGet("D1_DESPESA", i)
							nSeguro  := gdFieldGet("D1_SEGURO", i)
							nICMSRet := gdFieldGet("D1_ICMSRET", i)
							nValDesc := gdFieldGet("D1_VALDESC", i)
							nValICM  := gdFieldGet("D1_VALICM", i)
							nValIMP5 := gdFieldGet("D1_VALIMP5", i)
							nValIMP6 := gdFieldGet("D1_VALIMP6", i)
							nVSenar  := gdFieldGet("D1_VLSENAR", i) //Chamado 056841 - Abel Babini - 23/03/2020 - OS 058286 || FISCAL || ELIZABETE || 8954 || NF -  PRODUTOR RURAL || Descontar o valor do SENAR

							If Left(AllTrim(cCFOP),1) == "3" // Moeda Estrangeira

								nTtNF += nTt + nValIPI + nValFre + nDespesa + nSeguro + nValICM + nValImp5 + nValImp6 + nICMSRet - nValDesc

							Else

								nTtNF += nTt + nValIPI + nValFre + nDespesa + nSeguro + nICMSRet - nValDesc - nVSenar //Chamado 056841 - Abel Babini - 23/03/2020 - OS 058286 || FISCAL || ELIZABETE || 8954 || NF -  PRODUTOR RURAL || Descontar o valor do SENAR

							EndIf

						EndIf

						// Consisto qtd parcelas PC x NF
						aAreaSC7 := SC7->( GetArea() )

						cPC     := gdFieldGet("D1_PEDIDO", i)
						cPCItem := gdFieldGet("D1_ITEMPC", i)

						// ORDER 1 = C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN                                                                                                                              
						cCondPC := Posicione("SC7",1,FWxFilial("SC7")+cPC+cPCItem,"C7_COND")
						
						aParcPC := Condicao(__MTCOLSE2,cCondPC,,dDataBase)
						aParcNF := Condicao(__MTCOLSE2,cCondicao,,dDataBase)

						RestArea( aAreaSC7 )

						If !Empty(cPC) .AND. (!Empty(cTesPcNf) .AND. !aCols[n][nPosTes] $ cTesPcNf) //Ticket 10404 - 05/03/2021 - ADRIANO SAVOINE 
							// Tratamento consistencia notas sem PC - FWNM - 10/12/2019
							If Len(aParcPC) <> Len(aParcNF)
								_lRet := .f.
								Alert( "[MT100TOK-08] - Quantidade de parcelas entre PC e NF estão divergentes! Verifique..." + chr(13) + chr(10) + ;
									"Condição Pagamento PC: " + cCondPC + chr(13) + chr(10) + ;
									"Condição Pagamento NF: " + cCondicao )
								Return _lRet
							EndIf
						EndIf
					EndIf
				Next i

				// Comparo totais - variavel publica __MTCOLSE2 contida no PE MTCOLSE2
				If !Empty(cPC) // Tratamento consistencia notas sem PC - FWNM - 10/12/2019
					
					If __MTCOLSE2 <> nTtNF // Chamado n. 053639 || OS 056753 || FISCAL || DEJAIME || 8921 || VAL. NF X DUPLICATA - FWNM - 28/01/2020

						_lRet := .f.
						Alert( "[MT100TOK-07] - Valor total das duplicatas difere do valor total da NF! Verifique..." + chr(13) + chr(10) + ;
							"Valor Total XML: " + Transform(nTtNF,"@E 999,999,999.9999") + chr(13) + chr(10) + ;
							"Valor Total Duplicatas: " + Transform(__MTCOLSE2,"@E 999,999,999.99") )
						//ClearGlbValue(__MTCOLSE2)
						Return _lRet

					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	//fernando sigoli Chamado: 042791 - 31/07/2018
	If !IsInCallStack( "U_CENTNFEXM" )

		cSpecLo := IIF(AllTrim(FunName()) == "MATA116",c116Especie,IIF(AllTrim(FunName()) == "MATA920",c920Especi,cEspecie)) //050109 - Abel Babini 05/08/2019. Tratamento para inclusão de NF Manual de Saída (Complemento de ICMS)

	EndIF

	If Alltrim(FunName()) == "MATA920" .or. Alltrim(FunName()) == "SPEDNFE"
		Return(_lRet)
	End If

	_nPTES    := aScan( aHeader, {|x| x[2] = "D1_TES" } )
	_nPCLAS   := aScan( aHeader, {|x| x[2] = "D1_CLASFIS" } )
	_nPProd   := aScan( aHeader, {|x| x[2] = "D1_COD" } )      //Mauricio - Chamado 035716 - 04/08/17 Nao permite produto sem local com tes atualiza estoque
	
	//Tratamento para validar TES utilizada e Classificacao Fiscal - Mauricio Chamado 009056 - Inicio
	For _i:=1 To Len(aCols)

		if !acols[_i][len(aheader)+1] //verifica se esta deletado

			_cTES  := aCols[_i][_nPTES]
			_cClas := aCols[_i][_nPCLAS]
			_cProd  := aCols[_i][_nPProd]        //Mauricio - Chamado 035716 - 04/08/17 Nao permite produto sem local com tes atualiza estoque
			_cLoc1 := Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_LOCPAD")  //Mauricio - Chamado 035716 - 04/08/17
			_cLoc2 := Posicione("SBZ",1,xFilial("SBZ")+_cProd,"BZ_LOCPAD")  //Mauricio - Chamado 035716 - 04/08/17

			// FWNM - 18/07/2018 - CHAMADO JAIR - PROJETOS INVESTIMENTOS
			cTES   := gdFieldGet("D1_TES", _i)
			cCC    := gdFieldGet("D1_CC", _i)
			cPC    := gdFieldGet("D1_PEDIDO", _i)
			cItmPC := gdFieldGet("D1_ITEMPC", _i)
			cPrj   := gdFieldGet("D1_PROJETO", _i)

			// Projetos Investimentos
			If Left(AllTrim(cCC),1) == "9"

				// Garante que o código do projeto sera igual ao do PC
				aAreaSC7 := SC7->( GetArea() )

				SC7->( dbSetOrder(1) ) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
				If SC7->( dbSeek(FWxFilial("SC7")+cPC+cItmPC) )
					gdFieldPut("D1_PROJETO", SC7->C7_PROJETO, _i)
				EndIf

				RestArea( aAreaSC7 )

				// Permite NF sem PC apenas para TES que não gere duplicata
				cDupl := ""
				aAreaSF4 := SF4->( GetArea() )

				SF4->( dbSetOrder(1) ) // F4_FILIAL+F4_CODIGO
				If SF4->( dbSeek(FWxFilial("SF4")+cTES) )

					cDupl := SF4->F4_DUPLIC

					If cDupl == "S"

						cPC    := gdFieldGet("D1_PEDIDO", _i)
						cItmPC := gdFieldGet("D1_ITEMPC", _i)

						If Empty(cPC) .or. Empty(cItmPC)

							_lRet := .f.
							msgAlert("Notas de projetos de investimentos exigem pedidos de compras e seu respectivo item!")

						EndIf
					EndIf
				EndIf

				RestArea( aAreaSF4 )

			EndIf
			// FWNM - FIM

			dbSelectAreA("SF4")
			dbSetOrder(1)
			dbSeek( xFilial("SF4") + aCols[_i][_nPTES] )

			IF found()

				if substr(aCols[_i][_nPCLAS],2,2) <> SF4->F4_SITTRIB

					MsgInfo("A Situacao tributaria desta NF esta diferente da classificacao fiscal cadastrada na TES."+chr(13)+chr(13)+"MT100TOK-01 Tecle enter no campo TES para atualizar!")
					_lRet := .F.

				Endif

				//Mauricio - Chamado 035716 - 04/08/17 Nao permite produto sem local com tes atualiza estoque
				If SF4->F4_ESTOQUE == "S" .And. Alltrim(cEmpAnt) $ "01/02"

					If Empty(_cLoc1) .And. Empty(_cLoc2)

						MsgInfo("Produto "+Alltrim(_cProd)+" sem LOCAL no cadastro de produtos."+chr(13)+chr(13)+"MT100TOK-02 Não pode utilizar este produto!")
						_lRet := .F.

					Endif
				Endif
			Endif
		endif
	Next

	// *** INICIO CHAMADO 041307 WILLIAM COSTA 01/05/2018 *** //
	IF ALLTRIM(CESPECIE) $ GetMV("MV_#ESPORI",,"CTE")

		IF VALTYPE(aInfAdic) == "A" .AND. ALLTRIM(aInfAdic[10]) == ''

			MsgStop("OLÁ " + Alltrim(cUserName) + ", Necessário adicionar UF ORIGEM DO TRANSPORTE por favor, verifique.", "MT100TOK-03  - Aba Informações ADicionais ")
			_lRet := .F.

		ELSEIF VALTYPE(aInfAdic) == "A" .AND. ALLTRIM(aInfAdic[11]) == ''

			MsgStop("OLÁ " + Alltrim(cUserName) + ", Necessário adicionar MUN ORIGEM DO TRANSPORTE por favor, verifique.", "MT100TOK-04  - Aba Informações ADicionais ")
			_lRet := .F.

		ELSEIF VALTYPE(aInfAdic) == "A" .AND. ALLTRIM(aInfAdic[12]) == ''

			MsgStop("OLÁ " + Alltrim(cUserName) + ", Necessário adicionar UF DESTINO DO TRANSPORTE por favor, verifique.", "MT100TOK-05  - Aba Informações ADicionais ")
			_lRet := .F.

		ELSEIF VALTYPE(aInfAdic) == "A" .AND. ALLTRIM(aInfAdic[13]) == ''

			MsgStop("OLÁ " + Alltrim(cUserName) + ", Necessário adicionar MUN DESTINO DO TRANSPORTE por favor, verifique.", "MT100TOK-06 - Aba Informações ADicionais ")
			_lRet := .F.

		ENDIF
	ENDIF
	// *** FINAL CHAMADO 041307 WILLIAM COSTA 01/05/2018 *** //

	//comentado 02/03/2017 - Fernando sigoli, entrada Central XML
	//Éverson - 01/03/2017. Chamado 033720.
	//If cEmpAnt = "01"
	//	if cFORMUL = 'N' .And. ! _SetAutoMode() .And. _lRet .And. ! vldEspiao()
	//		_lRet := .F.
	//	EndIf
	//Endif

	//Validacao padrao da Rotina / Execucao do lancamento de NF-e via Central XML
	//Fernando Sigoli 14/05/2018 Chamado: 041172
	If lPadrao

		If IsInCallStack( "U_RECNFEXML" )

			//Guarda a chave da Central XML
			cChvXML	:= Alltrim( RECNFXML->XML_CHAVE )
			nOpcVal	:= 1

		ElseIf IsInCallStack( "U_RECNFECTE" )

			//Guarda a chave da Central XML
			cChvXML	:= Alltrim( RECNFCTE->XML_CHAVE )
			nOpcVal	:= 2

		EndIf

		If !Empty( cChvXML )

			_lRet := ValidTot( cChvXML, nOpcVal )
			
		EndIf
	EndIf

	//inicio: Fernando Sigoli 05/06/2018 Chamado: 041718
	// Não validar qdo central xml
	If !IsInCallStack("U_CENTNFEXM") .And. !IsInCallStack("U_ADFIS032P") //Everson - 19/07/2019. Chamado 044314.

		// Consisto especies nao permitidas
		If AllTrim(cSpecLo) $ cEspBlq .and. cFormul <> 'S'

			// Consisto as empresas/filiais que não deverão sofrer consistências
			If !(AllTrim(cEmpAnt)+AllTrim(cFilAnt)) $ cEmpAut

				// Consisto o login que poderá incluir manualmente sem bloqueio
				If !(cLogAut $ AllTrim(__cUserID))

					// Validar somente no DOCUMENTO ENTRADA
					If AllTrim(FunName()) == "MATA103" .or. AllTrim(FunName()) == "MATA116"

						_lRet := .F.

						// Aviso ao usuario
						Aviso(	"MT100TOK-01",;
							"Espécie não permitida por esta rotina... Utilize a Central XML ou PRÉ-NOTA!" + chr(13) + chr(10) +;
							"" + chr(13) + chr(10) +;
							"" ,;
							{ "&OK" },,;
							"Espécie não permitida" )

					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	//Fim: Fernando Sigoli 05/06/2018 Chamado: 041718

	// Chamado n. 047942 || OS 049210 || FISCAL || SIMONE || 8463 || C.C 8011 (PC X D.E) - FWNM - 19/03/2019
	/*
	Detalhamento:
		- Reuniao realizada em 19/03/2019 com os responsaveis de TI
		- Definido que o codigo do centro de custo 8011 devera ser fixado aqui no fonte e nao podera ser tratado via parametro ou cadastro por questoes estrategicas e de seguranca
		- Objetivo: nao levar para a contabilidade este CC
	
	Ponto Atencao:
		- Tratamento devera ser sempre executado apos todas as consistencias acima existentes !!!
	*/

	For i:=1 to Len(aCols)

		cCC      := gdFieldGet("D1_CC", i)
		cPC      := gdFieldGet("D1_PEDIDO", i)
		cPCItem  := gdFieldGet("D1_ITEMPC", i)
		cItemNot := gdFieldGet("D1_ITEM", i)
		cProd    := gdFieldGet("D1_COD", i)

		If AllTrim(cCC) == "8011"

			gdFieldPut("D1_CC", "", i)

		EndIf
	
		// Chamado n. 057002 || OS 058479 || CONTROLADORIA || MONIK_MACEDO || 996108893 || CONTABILIZACAO - FWNM - 31/03/2020
		cProd := gdFieldGet("D1_COD", i)
		cTES := gdFieldGet("D1_TES", i)

		If AllTrim(Posicione("SF4",1,FWxFilial("SF4")+cTES,"F4_ESTOQUE")) == "N"

			cCta := Posicione("SB1",1,FWxFilial("SB1")+cProd,"B1_CONTAR")
			gdFieldPut("D1_CONTA",cCta,i)
			
		Else

			cCta := Posicione("SB1",1,FWxFilial("SB1")+cProd,"B1_CONTA")
			gdFieldPut("D1_CONTA",cCta,i)

		EndIf
		//

		// Chamado n. 057002 || OS 058479 || CONTROLADORIA || MONIK_MACEDO || 996108893 || CONTABILIZACAO - FWNM - 31/03/2020
		IF ALLTRIM(cPC) <> ''

			cCCPed := Posicione("SC7",1,FWxFilial("SC7")+cPC+cPCItem,"C7_CC")

			IF cCCPed <> cCC

				MsgStop("OLÁ " + Alltrim(cUserName) + ", Centro de Custo da Nota Fiscal não é o mesmo do pedido de compra, não é permitido, verifique!!!" + CHR(13) + CHR(10) + "Item da Nota: " + cItemNot + CHR(13) + CHR(10) + "Produto: " + cProd + CHR(13) + CHR(10) + "Centro de Custo Nota: " + cCC + CHR(13) + CHR(10) + "Centro de Custo Pedido: " + cCCPed , "MT100TOK-09  - Centro de Custo NF X PED COM")
				_lRet := .F.
			
			ENDIF
		ENDIF
	Next i

	//Everson - 09/05/2019. Chamado TI.
	If Len(Alltrim(DTOS(dDtLEmis))) > 0

		If DDEMISSAO <= dDtLEmis

			AVISO('Bloqueio de Data de Emissão', 'A data de emissão do documento é inferior ao permitido para digitação. Consulte o Depto. Fiscal!', {"Fechar"}, 1 )
			_lRet := .F.

		Endif
	Endif
	//

	//Everson - 10/05/2019. Chamado TI.
	If Empty(Alltrim(cValToChar(CESPECIE)))

		AVISO('Bloqueio de Espec. Docum.', 'É obrigatório informar a espécie do documento.', {"Fechar"}, 1 )
		_lRet := .F.

	EndIf

	RestArea(_aArea)

Return(_lRet)

/*/{Protheus.doc} Static Function vldEspiao
	Validação de NF utilizando os dados do software espião.
	@type  Static Function
	@author Everson
	@since 01/03/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function vldEspiao()

	//Declaração de variávies.
	
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local cFil		:= ""
	Local cFornec	:= ""
	Local cLj		:= ""
	Local cCNPJ		:= ""
	Local cNota		:= ""
	Local cSr	    := ""
	Local cEmissao	:= ""
	Local cTpDoc	:= ""
	Local nVlr		:= 0
	Local lRegEnc	:= .F.
	Local cQuery	:= ""
	Local cFilEsp	:= ""
	Local nVlrEsp	:= 0
	Local cEmisEsp	:= ""
	Local cMsg		:= ""
	Local PulLin	:= Chr(13) + Chr(10)
	Local cNotaEsp	:= ""
	Local cChave	:= Alltrim(cValToChar(aNFeDANFE[13])) //Chave do documento.
	Local i			:= 1
	Local nVlrSD1   := aScan(aHeader,{|x| x[2] = "D1_TOTAL"})
	Local nNfRural  := aScan(aHeader,{|x| x[2] = "D1_NFRURAL"})
	Local nSrRural  := aScan(aHeader,{|x| x[2] = "D1_SRRURAL"})

	//Valida nota fiscal eletrônica e conhecimento de transporte eletrônico.
	If Alltrim(cValToChar(CESPECIE)) == "SPED"

		cTpDoc := "1"

	ElseIf Alltrim(cValToChar(CESPECIE)) == "CTE"

		cTpDoc := "2"

	Else

		RestArea(aArea)
		Return lRet

	EndIf

	//Remove espaços em branco.
	cFil 	 := Alltrim(cValToChar(xFilial("SF1")))
	cFornec	 := Alltrim(cValToChar(CA100FOR))
	cLj		 := Alltrim(cValToChar(CLOJA))
	cEmissao := Alltrim(cValToChar(DToS(DDEMISSAO)))

	//Obtém o CNPJ do fornecedor/cliente.
	If cTipo $"D|B"

		cCNPJ	:= Alltrim(cValToChar(Posicione("SA1",1,xFilial("SA1")+cFornec+cLj,"A1_CGC")))

	Else

		cCNPJ	:= Alltrim(cValToChar(Posicione("SA2",1,xFilial("SA2")+cFornec+cLj,"A2_CGC")))

	EndIf

	//Obtém o número e série da nota fiscal.
	If Alltrim(cValToChar(CFORMUL)) == "N"

		cNota	:= Padl(Alltrim(cValToChar(CNFISCAL)),9,"0")
		cSr		:= Padl(Alltrim(cValToChar(CSERIE)),3,"0")

	Else

		cNota	:= Padl(Alltrim(cValToChar(aCols[i][nNfRural])),9,"0")
		cSr		:= Padl(Alltrim(cValToChar(aCols[i][nSrRural])),3,"0")

	EndIf

	//Monta script sql.
	cQuery := ""
	cQuery += " SELECT  "
	cQuery += " *  "
	cQuery += " FROM  "
	cQuery += " " + RetSqlName("ZBK") + " AS ZBK "
	cQuery += " WHERE "
	cQuery += " ZBK.D_E_L_E_T_ = '' "
	cQuery += " AND ZBK_CNPJ  = '" + cCNPJ + "' "

	If ! Empty(cChave)

		cQuery += " AND ZBK_CHAVE = '" + cChave + "' "

	Else

		cQuery += " AND ZBK_DOC   = '" + cNota + "' "

		If ! Empty(cSr)

			cQuery += " AND ZBK_SERIE = '" + cSr + "' "

		EndIf

	EndIf

	cQuery += " AND ZBK_TPDOC = '" + cTpDoc + "' "

	//Valida se o alias existe.
	If Select("TAB_ESP") > 0

		TAB_ESP->(DbCloseArea())

	EndIf

	//Executa consulta no BD.
	TcQuery cQuery New Alias "TAB_ESP"
	TAB_ESP->(DbGoTop())
	DbSelectArea("TAB_ESP")

	cFilEsp		:= Alltrim(cValtoChar(TAB_ESP->ZBK_FILIAL))
	nVlrEsp		:= Val(cValtoChar(TAB_ESP->ZBK_VALOR))
	cEmisEsp	:= Alltrim(cValtoChar(TAB_ESP->ZBK_DATA))
	cNotaEsp	:= Alltrim(cValtoChar(TAB_ESP->ZBK_DOC)) + Alltrim(cValtoChar(TAB_ESP->ZBK_SERIE))

	DbCloseArea("TAB_ESP")

	If ! Empty(cFilEsp)

		//Registro encontrado.
		lRegEnc := .T.

		nVlr := MaFisRet(,"NF_TOTAL") // Everson - 09/03/2017. Chamado 033958

		//Valida filial.
		If cFil <> cFilEsp

			cMsg += "Filial divergente Lanc: " + cFil + " Esp: " + cFilEsp + PulLin

		EndIf

		//Valida valor.
		If nVlr <> nVlrEsp

			cMsg += "Valor divergente Lanc: " + Alltrim(cValToChar(Transform(nVlr,"@E 999,999,999.99"))) + " Esp: " + Alltrim(cValToChar(Transform(nVlrEsp,"@E 999,999,999.99"))) + PulLin

		EndIf

		//Valida data de emissão.
		If cEmissao <> cEmisEsp

			cMsg += "Data de emissão divergente Lanc: " + DToC(SToD(cEmissao)) + " Esp: " + DToC(SToD(cEmisEsp)) + PulLin

		EndIf

		//Valida número da NF.
		If cNotaEsp <> cNota + cSr

			cMsg += "Número/série divergente Lanc: " + cNota + cSr + " Esp: " + cNotaEsp + PulLin

		EndIf

	EndIf

	//Solicita confirmação do usuário para prosseguir com o lançamento, mesmo apresentando divergências.
	If !lRegEnc

		If ! MsgYesNo("Não foi possível validar as informações com a base de dados do software Espião. Deseja prosseguir?","Função vldEspiao")

			lRet := .F.

		EndIf

	elseIf !Empty(Alltrim(cValToChar(cMsg)))

		if ! MsgYesNo("Atenção! Deseja prosseguir com o lançamento do documento fiscal? " + PulLin +;
				"As informações da nota fiscal apresentaram a(s) divergência(s) abaixo em comparação com o software Espião: " + PulLin +;
				cMsg,"Função vldEspiao")

			lRet := .F.

		endif
	endif

	//Gera log.
	DbSelectArea("ZBE")
	Reclock("ZBE",.T.)
	ZBE->ZBE_FILIAL	:= cFil
	ZBE->ZBE_DATA 	:= Date()
	ZBE->ZBE_HORA 	:= cValToChar(Time())
	ZBE->ZBE_USUARI := cUserName
	ZBE->ZBE_LOG 	:= "Registro encontrado: " + cValToChar(lRegEnc) + " | Divergências: " + cMsg + " | Prosseguiu: " + cValToChar(lRet)
	ZBE->ZBE_MODULO := "FISCAL"
	ZBE->ZBE_ROTINA := "MT100TOK"
	ZBE->ZBE_PARAME := "CNPJ" + cCNPJ + " | Num " + cNota + " | Série " + cSr + " | Formulario próprio " + Alltrim(cValToChar(CFORMUL)) + " | Tipo DOC " + cTipo + " | Espécie " + CESPECIE
	MsUnlock()
	ZBE->(DbCloseArea())

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} Static Function ValidTot
	Validação valor total da NF x XML (Central XML)
	@type  Static Function
	@author Fernando Sigoli
	@since 14/05/2018
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 041172
/*/

Static Function ValidTot( cChvXML, nOpcVal )

	Local cAlias	:= GetNextAlias()
	Local nTotXML	:= 0
	Local lRetorno	:= .T.
	Local nX		:= 0
	Local nPosTot	:= Ascan( aHeader, { |x| AllTrim( x[ 02 ] ) == "D1_TOTAL"		})
	Local nPosST	:= Ascan( aHeader, { |x| AllTrim( x[ 02 ] ) == "D1_ICMSRET"		})
	Local nPosIPI	:= Ascan( aHeader, { |x| AllTrim( x[ 02 ] ) == "D1_VALIPI"		})
	Local nPosFre	:= Ascan( aHeader, { |x| AllTrim( x[ 02 ] ) == "D1_VALFRE"		})
	Local nPosDes	:= Ascan( aHeader, { |x| AllTrim( x[ 02 ] ) == "D1_VALDESC"		})
	Local nValorF   := MaFisRet(,"NF_TOTAL")

	If nOpcVal == 1	//NF-e

		BeginSQL Alias cAlias

			SELECT	XML_CHAVE, XML_ARQ
			FROM 	RECNFXML
			WHERE	%NotDel%
			  AND	XML_CHAVE = %Exp:cChvXML%

		EndSQL

		//Varre Itens do XML
		If !( cAlias )->( Eof() )

			//nTotXML := nTotGXml
			nTotXML	:= Val( Substr( ( cAlias )->XML_ARQ, At( "<vNF",( cAlias )->XML_ARQ ) + 5, At( "</vNF>", ( cAlias )->XML_ARQ ) - At( "<vNF", ( cAlias )->XML_ARQ ) - 5 ) )

		EndIf

	Else //CT-e/CT-e OS

		BeginSQL Alias cAlias
			SELECT	XML_CHAVE,
					XML_TOTCTE
			FROM 	RECNFCTE
			WHERE	%NotDel%
				AND		XML_CHAVE = %Exp:cChvXML%

		EndSQL

		//Varre Itens do XML
		If !( cAlias )->( Eof() )

			//Total do CT-e fica no Cabecalho
			nTotXML	+= ( cAlias )->XML_TOTCTE

		EndIf

	EndIf

	( cAlias )->( DbCloseArea() )

	If round(nTotXML,2) <> round(nValorF,2)  .AND. !(cTipo $ 'I')	// Abel Babini - 11/06/2019 - Chamado Interno TI

		lRetorno	:= .F.
		Aviso( "Aviso", "Total XML R$ "+cvaltochar(round(nTotXML,2))+" difere com o total da NF R$ " +cvaltochar(round(nValorF,2))+ ", nota não poderá ser classificada", {"Ok"} )

	EndIf

Return lRetorno
/*/{Protheus.doc} Static Function ChkPrjPCNF
	Checa totais de QTD e VLR, do PC x NFs
	
	Caso:
	- O fiscal fez  lançamento do pedido 399573, valor R$ 80.000,00, porem a NF 000000036  valor (R$ 8.000,00), no entanto foi lançado o valor total, 
	  solicitei o ajuste pois o pedido estava acusando pagamento total.
	- O projeto até aquele momento estava positivo em 65mil reais, após esse ajuste ficou negativo, precisamos entender o que foi feito, 
	  pois o projeto não consumiu o valor do pedido.

	PC foi lançado com
	quantidade = 1
	valor = R$ 80.000,00 (oitenta mil reais)

	NF foi lançado com
	quantidade = 1
	valor = R$ 8.000,00 (oito mil reais)
 
	=> Esta ação, fez com que o PC ficasse totalmente entregue (C7_QUJE = C7_QUANT), zerando o valor do consumo do projeto que era de R$ 80.000,00, 
	   passando então a considerar o valor da NF de R$ 8.000,00, liberando assim um saldo de R$ 72.000,00. 
	   Neste meio tempo, entre a identificação deste erro de lançamento na quantidade, houveram uma série de lançamentos de PCs e NFs, pois o projeto possuía saldo. 
	   A partir do momento que fizeram o ajuste na quantidade da NF, o PC voltou a ficar com saldo a entregar e o consumo voltou a somar os R$ 72.000,00 de consumo, 
	   negativando assim o projeto!

	@type  Function
	@author FWNM
	@since 18/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 14352   - Fernando Macieir		- 21/05/2021 - Saldo Negativo (identificamos que a solução do ticket 6652 não foi publicada!)
	@history ticket 68736   - Leonardo P. Monteiro 	- 23/02/2022 - Correção de error.log na consulta work.
/*/
Static Function ChkPrjPCNF(cPCPrj, cPCItem)

	Local lRet       := .t.
	Local i          := 0
	Local nTtQtd     := 0
	Local nTtVlr     := 0
	Local cQuery     := ""
	Local cNumPC     := ""
	Local aPCPrj     := Separa(cPCPrj, ";")
	Local aAreaSC7   := SC7->( GetArea() )
	Local nC7_TOTAL  := 0
	Local nTolera    := GetMV("MV_#PRJTOL",,10)
	Local lTolVlr    := GetMV("MV_#TOLVLR",,.F.)

	For i:=1 to Len(aCols)

		If !gdDeleted(i)

			If !Empty(AllTrim(gdFieldGet("D1_PROJETO",i))) .or. Left(AllTrim(gdFieldGet("D1_CC",i)),1) == "9"

				cNumPC     := gdFieldGet("D1_PEDIDO",i)
				cNumPCItem := gdFieldGet("D1_ITEMPC",i)

				If aScan(aPCPrj, {|x| x == cNumPC})

					nTtQtd := gdFieldGet("D1_QUANT",i)
					nTtVlr := gdFieldGet("D1_TOTAL",i)
			
					// base dados
					// Ticket 68736 - Correção de error.log 
					If Select("Work") > 0
						Work->( dbCloseArea() )
					EndIf

					cQuery := " SELECT ISNULL(SUM(D1_QUANT),0) D1_QUANT, ISNULL(SUM(D1_TOTAL),0) D1_TOTAL
					cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK)
					cQuery += " WHERE D1_PEDIDO='"+cNumPC+"' 
					cQuery += " AND D1_ITEMPC='"+cNumPCItem+"' 
					cQuery += " AND D_E_L_E_T_=''

					tcQuery cQuery New Alias "Work"

					aTamSX3	:= TamSX3("D1_QUANT")
					tcSetField("Work", "D1_QUANT", aTamSX3[3], aTamSX3[1], aTamSX3[2])

					aTamSX3	:= TamSX3("D1_TOTAL")
					tcSetField("Work", "D1_TOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2])

					Work->( dbGoTop() )
					If Work->( !EOF() )

						SC7->( dbSetOrder(1) ) // C7_FILIAL+C7_NUM+C7_ITEM
						If SC7->( dbSeek(FWxFilial("SC7")+cNumPC+cNumPCItem) )

							If (Work->D1_QUANT + nTtQtd) >= SC7->C7_QUANT

								nC7_TOTAL := SC7->C7_TOTAL
								If SC7->C7_MOEDA >= 2
									nC7_TOTAL := Round(SC7->C7_TOTAL * SC7->C7_XTXMOED,2)
								EndIf

								If lTolVlr // Param que liga/desliga a tolerância por valor/percentual
									
									// Cálculo da tolerância por valor 
									If ( (Work->D1_TOTAL + nTtVlr) + nTolera ) < nC7_TOTAL
										lRet := .f.
										Exit
									EndIf
								
								Else
								
									// Cálculo da tolerância por percentual (default)
									If ( (Work->D1_TOTAL + nTtVlr) + (nTtVlr * (nTolera/100)) ) < nC7_TOTAL
										lRet := .f.
										Exit
									EndIf
								EndIf

							EndIf
						
						EndIf

					EndIf

				EndIf

				// @history ticket 16401   - Fernando Macieir- 12/07/2021 - Saldo Negativo (PC com qtd parcial, porém, valor unitário muito diferente do PC e também com valor total muito próximo do PC)
				SC7->( dbSetOrder(1) ) // C7_FILIAL+C7_NUM+C7_ITEM
				If SC7->( dbSeek(FWxFilial("SC7")+cNumPC+cNumPCItem) )

					nPrcC7 := SC7->C7_PRECO
					nTotC7 := SC7->C7_TOTAL
					
					nPrcD1 := gdFieldGet("D1_VUNIT",i)
					nTotD1 := gdFieldGet("D1_TOTAL",i)

					// Valor unitário da NF muito maior que o contido no PC (exemplo: PV A04H7M, NF 000203477)
					If nPrcD1 > (nPrcC7 + (nPrcC7 * (nTolera/100)))

						lRet := .f.

						Aviso( "MT100TOK-12",;
							"Valor unitário da NF muito maior que o contido no PC! Verifique... " + chr(13) + chr(10) +;
							"MV_#PRJTOL permite tratar exceções... " + chr(13) + chr(10) + chr(13) + chr(10) +;
							"" + chr(13) + chr(10) +;
							"" ,;
							{ "&OK" },,;
							"Projeto de Investimento ficará negativo no futuro após reprocessamento!" )

						Exit

					EndIf

					// Valor total da NF muito maior que o contido no PC (exemplo: PV A04H7M, NF 000203477)
					If nTotD1 > (nTotC7 + (nTotC7 * (nTolera/100)))

						lRet := .f.

						Aviso( "MT100TOK-13",;
							"Valor Total da NF muito maior que o contido no PC! Verifique... " + chr(13) + chr(10) +;
							"MV_#PRJTOL permite tratar exceções... " + chr(13) + chr(10) + chr(13) + chr(10) +;
							"" + chr(13) + chr(10) +;
							"" ,;
							{ "&OK" },,;
							"Projeto de Investimento ficará negativo no futuro após reprocessamento!" )

						Exit

					EndIf

				EndIf
			
			EndIf
			//

		EndIf

	Next i

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	RestArea( aAreaSC7 )

Return lRet
