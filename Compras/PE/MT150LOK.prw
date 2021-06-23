#Include "Protheus.ch"
/*/{Protheus.doc} User Function nomeFunction
	Negociação e Cotação
	Responsável por verificar se a linha digitada está Ok
	@type  Function
	@author Fernando Macieira 
	@since 08/01/2019
	@version 01
	@history Chamado 046284 - fwnm - 08/01/2019 - Novas regras alteracao valor
	@history Chamado 047931 || OS 049195 || CONTROLADORIA || ANDRESSA || 45968437 || C.CUSTO X LOTE -RNX2 - FWNM - 19/03/2019
	@history Chamado 048414 || OS 049698 || CONTROLADORIA || ANDRESSA || 45968437 || NOTAS -LOTE RNX2 - FWNM - 10/04/2019
	@history Everson, 04/11/2020, Chamado 2562. Tratamento para gravar o número do estudo do projeto.
	/*/
User Function MT150LOK()

	//????????????????????????????????????
	//?Declara?o de vari?ies.
	//????????????????????????????????????
	LOCAL aAreaAtu	:= GetArea()
	LOCAL lRetorno	:= .T.
	Local cNumSC    := ''
	Local nQtdSC    := 0
	Local nQuant    := 0
	Local cItemSC   := ''
	
	//Everson - 12/11/2017.
	Local cFilCot	:= ""
	Local cNumCot	:= ""
	Local cCodForn	:= ""
	Local cLojForn	:= ""
	Local cItemCot	:= ""
	Local cNumPro	:= ""
	Local cItemGrd	:= ""
	
	// FWNM - 16/02/2018 - Projetos Investimentos
	Local lSldAtv   := GetMV("MV_#PRJSLD",,".T.")
	Local cFasePrj  := GetMV("MV_PRJINIC",,"05")
	
	// Chamado n. 046284
	Local cFaseRej := GetMV("MV_#FASREJ",,"01")
	Local cFaseApr := GetMV("MV_#FASEOK",,"03")
	//  

	If (cEmpAnt == "01" .And. xFilial("SC8") = "03")
		
		//
		cFilCot		:= xFilial("SC8")
		cNumCot		:= cA150Num
		cCodForn	:= cA150Forn
		cLojForn	:= cA150Loj
		cItemCot	:= aCols[n,aScan(aHeader,{|x| AllTrim(x[2]) == "C8_ITEM"})]
		cNumPro		:= aCols[n,aScan(aHeader,{|x| AllTrim(x[2]) == "C8_NUMPRO"})]
		cItemGrd	:= aCols[n,aScan(aHeader,{|x| AllTrim(x[2]) == "C8_ITEMGRD"})]
		
		cNumSC    := Posicione("SC8",1, cFilCot + cNumCot + cCodForn + cLojForn + cItemCot + cNumPro + cItemGrd,"C8_NUMSC")
		cItemSC   := Posicione("SC8",1, cFilCot + cNumCot + cCodForn + cLojForn + cItemCot + cNumPro + cItemGrd,"C8_ITEMSC")
		
		If Alltrim(aCols[n,aScan(aHeader,{|x| AllTrim(x[2]) == "C8_CC"})]) == "8001" .AND. ;
			!Empty(cNumSC)
			
			cItemSC := IIF(ALLTRIM(cItemSC) == '',Alltrim(aCols[n,aScan(aHeader,{|x| AllTrim(x[2]) == "C8_ITEM"})]),ALLTRIM(cItemSC))
			nQtdSC  := Posicione("SC1",1,xFilial("SC1") + Alltrim(cNumSC) + Alltrim(cItemSC),"C1_QUANT")
			nQuant  := aCols[n,aScan(aHeader,{|x| AllTrim(x[2]) == "C8_QUANT"})]
			
			//
			If nQuant <> nQtdSC
				
				Aviso(	"MT150LOK",;
				"Quantidade na Cotação: "+Alltrim(TRANSFORM(nQuant,"@E 99999999.9999"))+" ?diferente da Quantidade Solicitada: "+;
				Alltrim(TRANSFORM(nQtdSC,"@E 99999999.9999"))+"." + ' Favor verificar!!!',;
				{ "&Retorna" },,;
				"Diverg?cia COTAÇÃO x SOLICITAÇÃO DE COMPRA" )
				lRetorno	:= .F.
				
			EndIf
			
		EndIf
		
	EndIf
	
	// Projetos investimentos - FWNM - 16/02/2018
	
	// Consiste saldo do projeto de investimento
	If lRetorno
		
		If !gdDeleted(n)
			
			cPrj    := gdFieldGet("C8_PROJETO", n)
			cCC     := gdFieldGet("C8_CC", n)
			nTtPrj  := gdFieldGet("C8_TOTAL", n)
			
			dDtDig := msDate()
			
			// Garanto que os dados do projeto (CC, CONTA e PROJETO) estão iguais ao da SC pois sao vitais para as consistencias abaixo - FWNM - CHAMADO N. 043947 (Reginaldo Fragian)
			cNumSC  := gdFieldGet("C8_NUMSC", n)
			cItemSC := gdFieldGet("C8_ITEMSC", n)
	
			aAreaSC1 := SC1->( GetArea() )	
			
			SC1->( dbSetOrder(1) ) // C1_FILIAL + C1_NUM + C1_ITEM
			If SC1->( dbSeek( FWxFilial("SC1")+cNumSC+cItemSC ) )
							
				gdFieldPut("C8_PROJETO", SC1->C1_PROJADO, n)
				gdFieldPut("C8_CC", SC1->C1_CC, n)
				gdFieldPut("C8_CONTA", SC1->C1_CONTA, n)
				gdFieldPut("C8_XITEMST", SC1->C1_XITEMST, n) //Everson - 04/11/2020. Chamado 2562.
				
				// Chamado n. 047931 || OS 049195 || CONTROLADORIA || ANDRESSA || 45968437 || C.CUSTO X LOTE -RNX2 - FWNM - 19/03/2019
				If cEmpAnt $ GetMV("MV_#ZCNEMP",,"07")
					gdFieldPut("C8_XLOTECC", SC1->C1_XLOTECC, n)
					gdFieldPut("C8_XDLOTCC", SC1->C1_XDLOTCC, n)
				EndIf
				//
							
			EndIf
			
			RestArea( aAreaSC1 )
			//
			
			// 23/03/2018 - FWNM - Consiste Projeto Encerrado
			dbSelectArea("AF8")
			dbSetOrder(1)
			If dbseek(FWxFilial("AF8")+cPrj)
				If AllTrim(AF8->AF8_ENCPRJ) == "1"
					MsgAlert("O Projeto "+cPrj+" se encontra ENCERRADO e nao aceita mais lancamentos.")
					lRetorno := .f.
				EndIf
			EndIf
			
			// Consiste qdo prj de investimento
			If lRetorno
				
				lPrjInv := Left(AllTrim(cCC),1) == "9"
				
				// qdo prj investimento
				If lPrjInv .and. !Alltrim(cCC) $ GetMV("MV_#CCPADR")
					
					If Empty(cPrj)
						lRetorno := .f.
						
						Aviso(	"MT150LOK-02",;
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
							
							Aviso(	"MT150LOK-04",;
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
							
							Aviso(	"MT150LOK-05",;
							"Este projeto n. " + AllTrim(cPrj) + " não pertence a esta filial! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
							"Filial/Planta: " + cFilAnt + chr(13) + chr(10) +;
							"Projeto/Planta: " + Left(AllTrim(cPrj),2),;
							{ "&Retorna" },,;
							"Projeto x Filial/Planta" )
							
						EndIf
						
					EndIf
					
					// consiste valor/saldo, fase e vigencia
					If lRetorno
						
						If !Empty(cPrj)
							
							AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
							If AF8->( dbSeek(xFilial("AF8")+cPrj) )
								
								
								// Controle Saldo Projeto ativo
								If lSldAtv
									
									// Consiste apenas projetos que possuem valor
									If AF8->AF8_XVALOR > 0
										
										// Consiste saldo informado no documento de entrada x saldo do projeto (AF8)
										nSldPrj := u_ADCOM017P(cPrj)
										
										If nTtPrj > nSldPrj
											
											lRetorno := .f.
											
											Aviso(	"MT150LOK-07",;
											"Saldo do projeto n. " + AllTrim(cPrj) + " insuficiente! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
											"[Cotação] Líquido: " + Transform(nTtPrj, PesqPict("SC8","C8_TOTAL")) + chr(13) + chr(10) +;
											"[Projeto] Saldo: " + Transform(nSldPrj, PesqPict("SC8","C8_TOTAL")),;
											{ "&Retorna" },,;
											"Projeto sem saldo" )
											
										EndIf
										
										
										// Consiste fase do projeto para checar se esta na central de aprovacao
										If lRetorno
											
											// If AllTrim(cFasePrj) == AllTrim(AF8->AF8_FASE)// Chamado n. 046284
											If AllTrim(AF8->AF8_FASE) <> AllTrim(cFaseApr) // Se fase diferente de aprovada // Chamado n. 046284
												
												lRetorno := .f.
												
												Aviso(	"MT150LOK-01",;
												"Projeto n. " + AllTrim(cPrj) + " não foi aprovado na Central de Aprovação! " + chr(13) + chr(10) + "Uso ainda não permitido..." + chr(13) + chr(10) + ;
												"",;
												{ "&Retorna" },,;
												"Projeto não aprovado" )
												
											EndIf
										EndIf
										
										
										// Consiste datas previstas do projeto (AF8) x data de digitação oriunda do servidor do documento
										If lRetorno
											
											If dDtDig < AF8->AF8_START .or. dDtDig > AF8->AF8_FINISH
												
												lRetorno := .f.
												
												Aviso(	"MT150LOK-03",;
												"Vigêcia do projeto n. " + AllTrim(cPrj) + " está fora! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
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
						
						Aviso(	"MT150LOK-08",;
						"Centro de Custo: " + cCC + "." + Chr(13) + Chr(10) +;
						"Não permitido o preenchimento do Projeto.",;
						{ "&Retorna" },,;
						"Não permitido informar projeto para CC que não é investimento" )
					EndIf
					
				EndIf
				
			EndIf
			
		EndIf
		
	EndIf
	
	// Chamado n. 048414 || OS 049698 || CONTROLADORIA || ANDRESSA || 45968437 || NOTAS -LOTE RNX2 - FWNM - 10/04/2019
	If lRetorno
		lRetorno := ChkZCN()
	EndIf
	//

	RestArea(aAreaAtu)

Return lRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT150LOK  ºAutor  ³Microsiga           º Data ³  04/10/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
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
	
		cCC := gdFieldGet("C8_CC", n)

		// Busca Lote recria da SC se nao foi informado
		cLoteZCN := gdFieldGet("C8_XLOTECC", n)
		If Empty(cLoteZCN)
			cNumSC  := gdFieldGet("C8_NUMSC", n)
			cItemSC := gdFieldGet("C8_ITEMSC", n)
	
			SC1->( dbSetOrder(1) ) // C1_FILIAL + C1_NUM + C1_ITEM
			If SC1->( dbSeek( FWxFilial("SC1")+cNumSC+cItemSC ) )
				gdFieldPut("C8_XLOTECC", SC1->C1_XLOTECC, n)
				gdFieldPut("C8_XDLOTCC", SC1->C1_XDLOTCC, n)
			EndIf
	    EndIf
		
		// Lote Recria informado
		cLoteZCN := gdFieldGet("C8_XLOTECC", n)
		If !Empty(cLoteZCN)

			ZCN->( dbSetOrder(1) ) // ZCN_FILIAL+ZCN_LOTE                                                                                                                                             
			If ZCN->( dbSeek( FWxFilial("ZCN")+cLoteZCN ) )
			
				// Consisto lote encerrado
				If AllTrim(ZCN->ZCN_STATUS) == "E" 
					lRet := .f.
					Alert("[MT150LOK-ZCN1] - Lote Recria com status Encerrado! Contate a contabilidade...")
				EndIf
				
				// Consisto CC informado
				If lRet
					If AllTrim(cCC) <> AllTrim(ZCN->ZCN_CENTRO)
					  lRet := .f.
					  Alert("[MT150LOK-ZCN2] - Lote Recria não amarrado com o Centro de Custo informado! Contate a contabilidade...")
					EndIf
				EndIf
				
			Else
			
				// Lote informado nao cadastrado na ZCN
				lRet := .f.
				Alert("[MT150LOK-ZCN3] - Lote Recria não cadastrado! Contate a contabilidade...")

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
						Alert("[MT150LOK-ZCN4] - Centro de Custo informado possui Lote Recria amarrado! Informe o Lote Recria ou contate a contabilidade...")
					EndIf
		
				EndIf
	
			EndIf
		EndIf
		//
	
	EndIf
	
	RestArea( aAreaZCN )
	RestArea( aAreaSC1 )

Return lRet
