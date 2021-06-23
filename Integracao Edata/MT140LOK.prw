#include "protheus.ch"
#Include "Topconn.ch"

#Define STR_LF Chr(13)+ Chr(10)

/*/{Protheus.doc} User Function MT140LOK
	P.E tem o objetivo de validar as informações preenchidas no aCols de cada item do pré-documento de entrada
	@type  Function
	@author Microsiga
	@since 13/12/2013
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Ticket 352     - FWNM              - 24/08/2020 - Criar inteligência para não considerar saldo duplicado no momento da classificação
	@history ticket 14352   - Fernando Macieira - 25/05/2021 - Saldo Negativo
	@history ticket 14709   - Fernando Macieira - 26/05/2021 - Erro Pedido A04DNY - moeda Euro
	@history ticket 15094   - Fernando Macieira - 07/06/2021 - Valor unitário PC x NF
/*/
User Function MT140LOK()

	Local nTt      := 0
	Local nDesc    := 0
	Local nTtPrj   := 0
	Local lSldAtv  := GetMV("MV_#PRJSLD",,".T.")
	Local cFasePrj := GetMV("MV_PRJINIC",,"05")
	Local cFaseRej := GetMV("MV_#FASREJ",,"01")
	Local cFaseApr := GetMV("MV_#FASEOK",,"03")
	Local lGeraFin := .T. //Everson - 11/12/2018. Chamado 045702.
	Local lICMSPro := .F. 

	Local nPOSPROJ := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_PROJETO" })
	Local _nPosCta := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_CONTA"		})
	Local _nPosCC  := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_CC"	 		})
	Local _nPosCLVL:= aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_CLVL" 		})
	Local _nPosTes := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_TES" 		})
	Local _nPCOD   := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_COD" 		})
	Local _nPTES   := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_TES" 		})
	Local _nPCONTA := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_CONTA" 	    })
	Local _nPCC    := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_CC" 	    	})
	Local _nNFORI  := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_NFORI" 	    })
	Local _nSERIE  := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_SERIE" 	    })
	Local _nFORNE  := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_FORNECE" 	})
	Local _nLOJA   := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_LOJA" 		})
	Local _nCOD    := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_COD" 		})
	Local _nPITCTA := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_ITEMCTA" 	})
	Local _nRateio := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_RATEIO" 	    })
	Local _nPosLoc := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_LOCAL"	    })
	Local _nCQUANT := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_QUANT"		})
	Local _nCVLUNI := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_VUNIT" 		})
	Local _nCTOTAL := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_TOTAL"		})
	Local _nCPEDID := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_PEDIDO"		})
	Local _nCITEMP := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_ITEMPC"		})
	Local _nNFPR  := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_NFRURAL"      })  // NF DO PRODUTOR RURAL
	Local _nSRPR  := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_SRRURAL"	    })  // SÉRIE DA NF DO PRDUTOR RURAL
	Local _nCf      := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_CF"      })
	Local _nNfFilOr := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_FILNFOR" })
	Local _nNfOrdem := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_NFORDEM" })
	Local _nSeriOrd := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_SERIORD" })
	Local _nItemOrd := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_ITEMORD" })
	Local _nForOrde := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_FORORDE" })
	Local _nLojaOrd := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_LOJAORD" })
	Local _nUM      := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_UM" })
	Local nSerOri   := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_SERIORI"})
	Local cTipoNF   := cTipo 	//Everson - 01/03/2019. Chamado T.I.
	Local cMsgErro  := "" 		//Everson - 13/03/2019. Chamado 047620.

	_lRet       := .T.
	_nPosOcor 	:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="D1_CTRDEVO"})
	_nPosUM 	:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="D1_UM"})
	nCont       := 0

	If Alltrim(Funname()) <> "CENTNFEXM"   //este ponto funciona para as rotinas padroes . Para a Central XML, estamos tratando a validação pelo P.E CEXMITNFE
										//Fernando Sigoli - Fernando Sigoli 01/03/2018
		If cTipo== "D"
		
			// INICIO CHAMADO 024498 - WILLIAM COSTA
			FOR nCont := 1 TO LEN(aCols)
			
				If Empty(aCols[nCont,_nPosOcor]) 
					Aviso("MT140LOK","Ocorrência não informada!",{"OK"},3)
					_lRet := .F.  
				ELSE    
					
					_lRet := .T.  
					EXIT
					
				ENDIF
			
			NEXT nCont
			// FINAL CHAMADO 024498 - WILLIAM COSTA
			
			If Empty(aCols[n,_nPosUM]) 
				Aviso("MT140LOK","Unidade de Medida não informada!",{"OK"},3)
				_lRet := .F.
			EndIf
		
		EndIf

	EndIF

	// @history Ticket 352     - FWNM              - 24/08/2020 - Criar inteligência para não considerar saldo duplicado no momento da classificação
	If _lRet
		
		If !gdDeleted(n)
			
			cPrj    := gdFieldGet("D1_PROJETO", n)
			cPC     := gdFieldGet("D1_PEDIDO", n)
			
			If Empty(cPC)
				dbSelectArea("AF8")
				dbSetOrder(1)
				If dbseek(xFilial("AF8")+cPrj)
					If AllTrim(AF8->AF8_ENCPRJ) == "1"
						MsgAlert("O Projeto "+cPrj+" se encontra ENCERRADO e nao aceita mais lancamentos.")
						_lRet := .f.
					EndIf
				EndIf
			EndIf
			
		EndIf
		
	EndIf
	
	// Consiste saldo do projeto de investimento
	If _lRet
		
		If !gdDeleted(n)
			
			dDtDig := msDate()
			
			cPrj    := gdFieldGet("D1_PROJETO", n)
			cCC     := gdFieldGet("D1_CC", n)
			cPC     := gdFieldGet("D1_PEDIDO", n)
			cPCItem := gdFieldGet("D1_ITEMPC", n)

			cNFCod  := gdFieldGet("D1_COD", n)
			cNFItem := gdFieldGet("D1_ITEM", n)

			nTt     := gdFieldGet("D1_TOTAL", n)
			nDesc   := gdFieldGet("D1_VALDESC", n)

			// Chamado n. RO || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 22/10/2019
			// Moeda Estrangeira = D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_VALICM+D1_VALIMP5+D1_VALIMP6+D1_ICMSRET-D1_VALDESC
			// Moeda Nacional    = D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_ICMSRET-D1_VALDESC

			cCFOP    := gdFieldGet("D1_CF", n)

			nValIpi  := gdFieldGet("D1_VALIPI", n)
			nValFre  := gdFieldGet("D1_VALFRE", n)
			nDespesa := gdFieldGet("D1_DESPESA", n)
			nSeguro  := gdFieldGet("D1_SEGURO", n)
			nICMSRet := gdFieldGet("D1_ICMSRET", n)
			nValDesc := gdFieldGet("D1_VALDESC", n)

			nValICM  := gdFieldGet("D1_VALICM", n)
			nValIMP5 := gdFieldGet("D1_VALIMP5", n)
			nValIMP6 := gdFieldGet("D1_VALIMP6", n)
			
			If Left(AllTrim(cCFOP),1) == "3" // Moeda Estrangeira
				nTtPrj := nTt + nValIPI + nValFre + nDespesa + nSeguro + nValICM + nValImp5 + nValImp6 + nICMSRet - nDesc
			Else
				nTtPrj := nTt + nValIPI + nValFre + nDespesa + nSeguro + nICMSRet - nDesc
			EndIf
			
			// Insere número do projeto do PC desde que esteja em branco, ou seja, não informado pelo usuario
			If Empty(cPrj)

				If !lICMSPro 

					aAreaSC7 := SC7->( GetArea() )
					
					SC7->( dbSetOrder(1) ) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
					SC7->( dbSeek(xFilial("SC7")+cPC+cPCItem) )
					
					cPrj := SC7->C7_PROJETO
					
					gdFieldPut("D1_PROJETO", cPrj, n)
					
					RestArea( aAreaSC7 )
				
				EndIf

			EndIf
			
			// Consiste exigência ou não do projeto
			lPrjInv := Left(AllTrim(cCC),1) == "9"
			
			If lPrjInv .and. !Alltrim(cCC) $ GetMV("MV_#CCPADR")
				
				If Empty(cPrj)
				
					If !lICMSPro 
				
						_lRet := .f.
						
						Aviso(	"MT140LOK-01",;
						"Centro de Custo: " + cCC + "." + Chr(13) + Chr(10) +;
						"É obrigatório o preenchimento do Projeto.",;
						{ "&Retorna" },,;
						"Conteúdo em Branco" )

					EndIf
				
				EndIf
				
				If !lICMSPro 
				
					// Consiste CC permitidos para aquele projeto (ZC1)
					If _lRet
						
						ZC1->( dbSetOrder(1) ) // ZC1_FILIAL+ZC1_PROJET+ZC1_CC
						If ZC1->( !dbSeek(xFilial("ZC1")+cPrj+cCC) )
							
							_lRet := .f.
							
							Aviso(	"MT140LOK-02",;
							"Centro Custo não permitido para este projeto! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
							"CC: " + cCC + " - " + Posicione("CTT",1,xFilial("CTT")+cCC,"CTT_DESC01") + chr(13) + chr(10) +;
							"Projeto: " + cPrj + " - " + AF8->AF8_DESCRI,;
							{ "&Retorna" },,;
							"Projeto x CC permitidos" )
							
						EndIf
						
					EndIf
					
					// Consiste filial/planta permitida para aquele CC
					If _lRet
						
						If Left(AllTrim(cPrj),2) <> cFilAnt
							
							_lRet := .f.
							
							Aviso(	"MT140LOK-03",;
							"Este projeto n. " + AllTrim(cPrj) + " não pertence a esta filial! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
							"Filial/Planta: " + cFilAnt + chr(13) + chr(10) +;
							"Projeto/Planta: " + Left(AllTrim(cPrj),2),;
							{ "&Retorna" },,;
							"Projeto x Filial/Planta" )
							
						EndIf
						
					EndIf
				
				EndIf //
				
				// consiste valor/saldo, fase e vigencia
				If _lRet
					
					If !Empty(cPrj)
						
						// Controle Saldo Projeto ativo
						If lSldAtv
							
							AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
							If AF8->( dbSeek(xFilial("AF8")+cPrj) )
								
								// Consiste apenas projetos que possuem valor
								If AF8->AF8_XVALOR > 0
									
									// Consiste fase do projeto para checar se esta na central de aprovacao
									If AllTrim(AF8->AF8_FASE) <> AllTrim(cFaseApr) // Se fase diferente de aprovada // Chamado n. 046284

										_lRet := .f.
										
										Aviso(	"MT140LOK-04",;
										"Projeto n. " + AllTrim(cPrj) + " não foi aprovado na Central de Aprovação! " + chr(13) + chr(10) + "Uso ainda não permitido..." + chr(13) + chr(10) + ;
										"",;
										{ "&Retorna" },,;
										"Projeto não aprovado" )
										
									EndIf
									
									// Consiste saldo informado no documento de entrada x saldo do projeto (AF8)
									If _lRet 
	
										// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 22/10/2019
										//If Empty(cPC) // FWNM - 20/12/2018 - Chamado n. 045963
										//

											cPCItemKey := ""
											cPCItemKey := cPC+cPCItem

											// @history Ticket 358     - FWNM            - 24/08/2020 - Implementação para diferenciar complemento de ICMS Próprio e ST nos projetos de investimentos
											cNFKey := ""
											cNFKey := FWxFilial("SF1")+cNFiscal+cSerie+cTipo+cA100For+cLoja
											
											nSldPrj := u_ADCOM017P(cPrj,,cPCItemKey,,cNFKey) 
											
											If (nTtPrj > nSldPrj) .And. lGeraFin 
												
												_lRet := .f.
												
												Aviso(	"MT140LOK-05",;
												"Saldo do projeto n. " + AllTrim(cPrj) + " insuficiente! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
												"[NF] Líquido: " + Transform(nTtPrj, PesqPict("SD1","D1_TOTAL")) + chr(13) + chr(10) +;
												"[PRJ] Saldo: " + Transform(nSldPrj, PesqPict("SD1","D1_TOTAL")),;
												{ "&Retorna" },,;
												"Projeto sem saldo" )
												
											EndIf
										
										//EndIf
						
									EndIf
									
									// Consiste datas previstas do projeto (AF8) x data de digitação oriunda do servidor do documento
									If _lRet
									
										// Inicio chamado William 04/03/2019 nova regra 047536 || OS 048806 || ALMOXARIFADO || FABIO || 8410 || BAIXA REQUISICAO    
										//Regra:Validar vigência do Projeto, somente se o documento de entrada não estiver com pedido de compra  amarrado e estiver número do projeto 
										//Analise se esse tratativa, seja no ponto de entrada LOK ou no TudoOK
										
										IF ALLTRIM(ACOLS[N][nPOSPROJ]) <> '' .AND.;
										   ALLTRIM(ACOLS[N][_nCPEDID]) == '' 
									
											If dDtDig < AF8->AF8_START .or. dDtDig > AF8->AF8_FINISH
												
												_lRet := .f.
												
												Aviso(	"MT140LOK-06",;
												"Vigência do projeto n. " + AllTrim(cPrj) + " está fora! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
												"Data Digitação: " + DtoC(dDtDig) + chr(13) + chr(10) +;
												"Início-Fim Projeto: " + DtoC(AF8->AF8_START) + " - " + DtoC(AF8->AF8_FINISH),;
												{ "&Retorna" },,;
												"Vigência do Projeto" )
												
											EndIf

										ENDIF

									EndIf
																	
								EndIf
								
							EndIf
							
						EndIf
						
					EndIf
					
				EndIf
				
			Else
				
				If !Empty(cPrj) .and. lICMSPro 
					
					_lRet := .f.
					
					If lICMSPro 
						Aviso(	"MT140LOK-07",;
						"Centro de Custo: " + cCC + "." + Chr(13) + Chr(10) +;
						"Não permitido o preenchimento do Projeto.",;
						{ "&Retorna" },,;
						"Não permitido informar projeto para nota de complemento de ICMS Próprio" )
					Else
						Aviso(	"MT140LOK-08",;
						"Centro de Custo: " + cCC + "." + Chr(13) + Chr(10) +;
						"Não permitido o preenchimento do Projeto.",;
						{ "&Retorna" },,;
						"Não permitido informar projeto para CC que não é investimento" )
					EndIf
					
				EndIf
				
			EndIf
					
		EndIf
		
	EndIf
	
	// FWNM - 23/03/2018 - Totaliza projetos informados nos itens para confrontar com o saldo do mesmo
	If _lRet
		
		// Controle Saldo Projeto ativo
		If lSldAtv
			
			aTtPrj := {} // armazenará os dados do projeto para totalizar e consistir
			
			For i:=1 to Len(aCols)
				
				If !gdDeleted(i)
					
					cPrj    := gdFieldGet("D1_PROJETO", i)
					cPC     := gdFieldGet("D1_PEDIDO", i) 
					
					If !Empty(cPrj)
						
						// Projeto Investimento
						cCC     := gdFieldGet("D1_CC", i)
						lPrjInv := Left(AllTrim(cCC),1) == "9"
						
						If lPrjInv .and. !Alltrim(cCC) $ GetMV("MV_#CCPADR")
							
							// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 22/10/2019
							//If Empty(cPC) // FWNM - 20/12/2018 - Chamado n. 045963
							//
							
								nTt     := gdFieldGet("D1_TOTAL", i)
								nDesc   := gdFieldGet("D1_VALDESC", i)
								cCC     := gdFieldGet("D1_CC", i)
								cPC     := gdFieldGet("D1_PEDIDO", i)
								cPCItem := gdFieldGet("D1_ITEMPC", i)
								
								// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 22/10/2019
								// Moeda Estrangeira = D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_VALICM+D1_VALIMP5+D1_VALIMP6+D1_ICMSRET-D1_VALDESC
								// Moeda Nacional    = D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_ICMSRET-D1_VALDESC

								//INICIO Chamado 055243 - Abel Babini     - 24/01/2020 - Ajuste na validação dos valores de saldo do Projeto MT140LOK-09 
								//alterado a posição 'n' para 'i'
								cCFOP    := gdFieldGet("D1_CF", i)
					
								nValIpi  := gdFieldGet("D1_VALIPI", i)
								nValFre  := gdFieldGet("D1_VALFRE", i)
								nDespesa := gdFieldGet("D1_DESPESA", i)
								nSeguro  := gdFieldGet("D1_SEGURO", i)
								nICMSRet := gdFieldGet("D1_ICMSRET", i)
								nValDesc := gdFieldGet("D1_VALDESC", i)
					
								nValICM  := gdFieldGet("D1_VALICM", i)
								nValIMP5 := gdFieldGet("D1_VALIMP5", i)
								nValIMP6 := gdFieldGet("D1_VALIMP6", i)
								//FIM Chamado 055243 - Abel Babini     - 24/01/2020 - Ajuste na validação dos valores de saldo do Projeto MT140LOK-09 
								
								If Left(AllTrim(cCFOP),1) == "3" // Moeda Estrangeira
									nTtPrj := nTt + nValIPI + nValFre + nDespesa + nSeguro + nValICM + nValImp5 + nValImp6 + nICMSRet - nDesc
								Else
									nTtPrj := nTt + nValIPI + nValFre + nDespesa + nSeguro + nICMSRet - nDesc
								EndIf

								// Valor do projeto do item
								//nTtPrj := (nTt - nDesc)
								//

								aAdd( aTtPrj, {	cPrj,;
								nTtPrj ,;
								cPC ,;
								cPCItem } )
								
							//EndIf
							
						EndIf
						
					EndIf
					
				EndIf
				
			Next i
			
			// Consisto total projeto
			
			// Ordena por Projeto + PC + Item PC
			aSort( aTtPrj,,, { |x,y| x[1]+x[3]+x[4] < y[1]+y[3]+y[4] } )
			
			cColsPrj    := ""
			nColsTot    := 0
			cColsPC     := ""
			cColsPCItem := ""
	
			cPCItemKey  := ""
			
			For y:=1 to Len(aTtPrj)
				
				cColsPC      := aTtPrj[y,3]
				cColsPCItem  := aTtPrj[y,4]
				
				// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 22/10/2019
				//If Empty(cColsPC) // FWNM - 20/12/2018 - Chamado n. 045963
				//
				
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
									
									// @history Ticket 358     - FWNM            - 21/08/2020 - Implementação para diferenciar complemento de ICMS Próprio e ST nos projetos de investimentos
									cNFKey := ""
									cNFKey := FWxFilial("SF1")+cNFiscal+cSerie+cTipo+cA100For+cLoja

									// Consiste saldo informado no documento de entrada x saldo do projeto (AF8)
									nSldPrj := u_ADCOM017P(cColsPrj,,cPCItemKey,,cNFKey)
													
									If nColsTot > nSldPrj .And. lGeraFin //Everson - 11/12/2018. Chamado 045702
										
										_lRet := .f.
										
										Aviso(	"MT140LOK-09",;
										"Saldo do projeto n. " + AllTrim(cColsPrj) + " insuficiente! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
										"[NF] Tt Líquido itens: " + Transform(nColsTot, PesqPict("SD1","D1_TOTAL")) + chr(13) + chr(10) +;
										"[PRJ] Saldo: " + Transform(nSldPrj, PesqPict("SD1","D1_TOTAL")),;
										{ "&Retorna" },,;
										"Projeto sem saldo" )
										
									Else
										// zero variaveis para proximo projeto
										cColsPrj     := aTtPrj[y,1]
										nColsTot     := aTtPrj[y,2]
										cColsPC      := aTtPrj[y,3]
										cColsPCItem  := aTtPrj[y,4]
										
									EndIf
									
								EndIf
								
							EndIf
							
						EndIf
						
					EndIf

				//EndIf
				
			Next y
			
			
			// Consisto o último projeto do acols - NÃO RETIRAR !!!
			If _lRet
				
				AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
				If AF8->( dbSeek(xFilial("AF8")+cColsPrj) )
					
					// Controle Saldo Projeto ativo
					If lSldAtv
						
						// Consiste apenas projetos que possuem valor
						If AF8->AF8_XVALOR > 0
							
							// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 22/10/2019
							//If Empty(cPCItemKey) // FWNM - 20/12/2018 - Chamado n. 045963
							//
							
								// @history Ticket 358     - FWNM            - 21/08/2020 - Implementação para diferenciar complemento de ICMS Próprio e ST nos projetos de investimentos
								cNFKey := ""
								cNFKey := FWxFilial("SF1")+cNFiscal+cSerie+cTipo+cA100For+cLoja

								// Consiste saldo informado no documento de entrada x saldo do projeto (AF8)
								nSldPrj := u_ADCOM017P(cColsPrj,,cPCItemKey,,cNFKey)
								
								If (nColsTot > nSldPrj) .And. lGeraFin //Everson - 11/12/2018. Chamado 045702
									
									_lRet := .f.
									
									Aviso(	"MT140LOK-10",;
									"Saldo do projeto n. " + AllTrim(cColsPrj) + " insuficiente! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
									"[NF] Tt Líquido itens: " + Transform(nColsTot, PesqPict("SD1","D1_TOTAL")) + chr(13) + chr(10) +;
									"[PRJ] Saldo: " + Transform(nSldPrj, PesqPict("SD1","D1_TOTAL")),;
									{ "&Retorna" },,;
									"Projeto sem saldo" )
									
								EndIf

							//EndIf
							
						EndIf
						
					EndIf
					
				EndIf
				
			EndIf
			
		EndIf
		
	EndIf
	//

	// @history ticket 14352   - Fernando Macieira - 25/05/2021 - Saldo Negativo
	If _lRet
		
		If !gdDeleted(n) .and. !Empty(gdFieldGet("D1_PROJETO", n)) // @history ticket 15094   - Fernando Macieira - 07/06/2021 - Valor unitário PC x NF
			_lRet := ChkTolera()
		EndIf

	EndIf
	//

Return(_lRet)

/*/{Protheus.doc} Static Function ChkTolera
	Checa tolerância de acordo com regras Adoro
	@type  Static Function
	@author Fernando Macieira
	@since 25/05/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ChkTolera()

	Local _lOK     := .t.
	Local aAreaSC7 := SC7->( GetArea() )
	Local aAreaSB1 := SB1->( GetArea() )
	Local cErroQtd := ""
	Local cGrupos  := Alltrim(cValToChar(GetMv("MV_#TOLQTD",,""))) //Everson - 18/12/2018. Chamado 045889.
	Local _qdtPed  := 0

	Local cPC      := gdFieldGet("D1_PEDIDO", n)
	Local cPCItem  := gdFieldGet("D1_ITEMPC", n)
	Local nQtdNF   := gdFieldGet("D1_QUANT", n)
	Local cUM      := gdFieldGet("D1_UM", n)
	Local cProd    := gdFieldGet("D1_COD", n)
	Local nVlrUni  := gdFieldGet("D1_VUNIT", n)

	SC7->( dbSetOrder(1) )
	If SC7->( dbSeek(FWxFilial("SC7") + cPC + cPCItem) )

		SB1->( dbSetOrder(1) )
		If SB1->( dbSeek(FWxFilial("SB1")+SC7->C7_PRODUTO) )
				
			//VALIDA QUANTIDADE COM TOLERANCIAS CONFORME GRUPO DE PRODUTOS
			cErroQtd := "Quantidade da NF está maior que a quantidade do item do pedido " + cPC + "/ " + cPCItem  + chr(13)+chr(10) + ;
						"Quantidade NF: " + TRANSFORM(nQtdNF, "@E 999,999,999.99") + chr(13)+chr(10) + "Quantidade PC: "

			If SB1->B1_GRUPO $ cGrupos  //MV_#TOLQTD
				
				_qdtPed := SC7->C7_QUANT - SC7->C7_QUJE
					
				If _qdtPed + (_qdtPed * (GETMV("MV_PERCEMB")/100) ) < nQtdNF
					_lOK := .F.
					Aviso("MT140LOK-11", (cErroQtd + TRANSFORM(_qdtPed, "@E 999,999,999.99") + chr(13)+chr(10)), { "&Retorna" },,"Grupos Produto: " + Alltrim(cGrupos) + chr(13)+chr(10) + ;
							"% Tolerancia: " + STR(GETMV("MV_PERCEMB"),3))
				EndIf

			EndIf

				// *** INICIO CHAMADO WILLIAM 038344 TOLERANCIA ACO,PEDRA,AREIA 21/02/2018 *** //
			If _lOK

				If FWxFilial("SF1") == GetMV("MV_#TOLFIL",,"03")              .AND. ;
				   SB1->B1_GRUPO $ GETMV("MV_#GRPEDR",,"9013/9015/9016/9017") .AND. ; //William Costa 11/03/2019 chamado 047734
				   AllTrim(cUM) <> 'UN'                                       .AND. ;
				   AllTrim(cUM) <> 'PC'
					
					_qdtPed := SC7->C7_QUANT - SC7->C7_QUJE
					
					If _qdtPed + (_qdtPed * (IIF(ALLTRIM(cProd) $ GETMV("MV_PEDAREI"), GETMV("MV_PERARE") /*10%*/, GETMV("MV_PERCACO") /*3%*/) / 100) ) < nQtdNF
						_lOK := .F.
						Aviso("MT140LOK-12", (cErroQtd + TRANSFORM(_qdtPed, "@E 999,999.99")+ STR_LF), { "&Retorna" },,"Grupos Produto: " + Alltrim(GETMV("MV_#GRPEDR",,"9013/9015/9016/9017")) + STR_LF + ;
							  "% Tolerancia: " + STR((IIF(ALLTRIM(cProd) $ GETMV("MV_PEDAREI"), GETMV("MV_PERARE") /*10%*/, GETMV("MV_PERCACO") /*3%*/)),3))
					Endif

				EndIf

			EndIf

			If _lOk

				// *** INICIO CHAMADO WILLIAM 046145 TOLERANCIA COZINHA 09/01/2019 *** //
				If AllTrim(SB1->B1_GRUPO) $ GETMV("MV_#GRUPOS",,"9028/") 
					
					_qdtPed := SC7->C7_QUANT - SC7->C7_QUJE
					
					If _qdtPed + (_qdtPed * (GETMV("MV_PERARE") / 100) ) < nQtdNF
						_lOK := .F.
						Aviso("MT140LOK-13", (cErroQtd + TRANSFORM(_qdtPed, "@E 999,999.99")+ STR_LF), { "&Retorna" },,"Grupos Produto: " + Alltrim(GETMV("MV_#GRUPOS",,"9028/")) + STR_LF + ;
								"% Tolerancia: " + STR(GETMV("MV_PERARE"),3))
					EndIf
					
				EndIf
			
			EndIf
			
			//VALIDA VALOR UNITARIO COM TOLERANCIAS CONFORME GRUPO DE PRODUTOS - PEDIDOS EM REAIS
			If _lOk

				If SC7->C7_MOEDA == 1 
				
					If SC7->C7_PRECO < nVlrUni
					
						cErroVunit := 	"Valor unitario da NF está maior que o Valor Unitario "+ STR_LF +"do item do Pedido " + Alltrim(cPC) + "/ " + ;
										cPCItem + STR_LF +;
										"Valor Unitario NF: R$" + TRANSFORM(nVlrUni, "@E 999,999.99") + STR_LF + ;
										"Valor Unitario PC: R$" + TRANSFORM(SC7->C7_PRECO, "@E 999,999.99")

										
						If AllTrim(SB1->B1_GRUPO) $ cGrupos  //MV_#TOLQTD 
							_lOK := .F.
							Aviso("MT140LOK-14", cErroVunit , { "&Retorna" },,"Grupos Produto: " + Alltrim(cGrupos) )
						EndIf
											
						If _lOk

							If FWxFilial("SF1") == GetMV("MV_#TOLFIL",,"03")              .AND. ;
								SB1->B1_GRUPO $ GETMV("MV_#GRPEDR",,"9013/9015/9016/9017") .AND. ; //William Costa 11/03/2019 chamado 047734
								AllTrim(cUM) <> 'UN'                                       .AND. ;
								AllTrim(cUM) <> 'PC'
							
								_lOK := .F.
								Aviso("MT140LOK-15", cErroVunit , { "&Retorna" },,"Atenção Grupos Produto: " + Alltrim(GETMV("MV_#GRPEDR",,"9013/9015/9016/9017")))

							EndIf

						EndIf

						If _lOk

							If AllTrim(SB1->B1_GRUPO) $ GETMV("MV_#GRUPOS",,"9028/") 
				
								_lOK := .F.
								Aviso("MT140LOK-16", cErroVunit , { "&Retorna" },,"Atenção Grupos Produto: " + Alltrim(cGrupos))
								
							Endif

						EndIf
					
					Endif

				Endif
				
			Endif
			
			//VALIDA TOTAL DO ITEM, CONSIDERANDO TOLERANCIAS CONFORME GRUPO DE PRODUTOS, CONSIDERANDO NF JA ENTREGUES - VALIDA TODOS OS ITENS
			// Trecho Original: Ricardo Lima-22/02/2019
			For nPc1:=1 To Len(aCols)		

				If aCols[nPc1] [LEN(aHeader) + 1] == .F.
							
					cCodpcnf := gdFieldGet( "D1_PEDIDO" , nPc1 )
					cItepcnf := gdFieldGet( "D1_ITEMPC" , nPc1 )
					nVlrttnf := 0
					nVlrnflc := 0
					nVlrDlr  := 0
					cSimbMoe := "R$"
				
					SC7->( dbSetOrder(1) )
					If SC7->( dbSeek( FWxFilial("SC7") + cCodpcnf + cItepcnf ) )

						IF SC7->C7_MOEDA > 1

							cSimbMoe := Alltrim(GETMV("MV_SIMB"+STR(SC7->C7_MOEDA,1),,""))

							IF SC7->C7_TXMOEDA == 0

								SM2->( DbSetOrder(1) )
								If SM2->( dbSeek(DtoS(dDEmissao)) )
									//nVlrDlr := &("M2_MOEDA"+STR(SC7->C7_MOEDA,1)) // @history ticket 14709   - Fernando Macieira - 26/05/2021 - Erro Pedido A04DNY - moeda Euro
									nVlrDlr := &("SM2->M2_MOEDA"+STR(SC7->C7_MOEDA,1)) // @history ticket 14709   - Fernando Macieira - 26/05/2021 - Erro Pedido A04DNY - moeda Euro
									If nVlrDlr == 0
										_lOK := .F.
										Aviso("MT140LOK-17","Pedido de compra na moeda "+STR(SC7->C7_MOEDA,1)+" sem cotacao, verifique cadastro de moedas dia: "+DTOC(ddEmissao), { "&Retorna" },,"Taxa zero")
									Endif
								Else
									_lOK := .F.
									Aviso("MT140LOK-18","Pedido de compra na moeda "+STR(SC7->C7_MOEDA,1)+" sem cotacao cadastrada na data: "+DTOC(ddEmissao), { "&Retorna" },,"Taxa não encontrada")
								Endif

							Else
								nVlrDlr := SC7->C7_TXMOEDA
							ENDIF

							cQuery := " SELECT F1_STATUS, D1_FILIAL, D1_PEDIDO, D1_ITEMPC, ISNULL(SUM(TOTAL/TAXA),0) D1_TOTAL "
							cQuery += " FROM ( "
							cQuery += " SELECT F1_STATUS, D1_FILIAL, D1_PEDIDO, D1_ITEMPC, D1_EMISSAO, D1_TOTAL-D1_VALDEV TOTAL,
							cQuery += " (SELECT C7_MOEDA FROM "+RetSqlName("SC7")+" C7 (NOLOCK) WHERE C7_FILIAL = '"+FWxFilial("SC7")+"' AND C7_NUM = '"+cCodpcnf+"' AND C7.D_E_L_E_T_ = ' ' ) MOEDA,"
							cQuery += " (SELECT M2_MOEDA"+STR(SC7->C7_MOEDA,1)+" FROM "+RetSqlName("SM2")+" M2 (NOLOCK) WHERE M2_DATA = D1_EMISSAO AND M2.D_E_L_E_T_='' ) TAXA "
							cQuery += " FROM "+RetSqlName("SD1")+" SD1 (NOLOCK) "
							cQuery += " INNER JOIN "+RetSqlName("SF1")+" SF1 ON SD1.D1_DOC = SF1.F1_DOC AND SD1.D1_SERIE = SF1.F1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SF1.F1_LOJA " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli
							cQuery += " WHERE D1_FILIAL = '"+FWxFilial("SD1")+"' "
							cQuery += " AND D1_PEDIDO = '"+cCodpcnf+"' AND D1_ITEMPC = '"+cItepcnf+"' "
//							cQuery += " AND D1_TES <> ' ' " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli 
							cQuery += " AND SF1.F1_STATUS <> '' " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli
							cQuery += " AND SF1.D_E_L_E_T_ = '' " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli
							cQuery += " AND SD1.D_E_L_E_T_ = '') NOTA "
							cQuery += " GROUP BY F1_STATUS, D1_FILIAL, D1_PEDIDO, D1_ITEMPC " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli
			
							If Select("ADMT100") > 0
								ADMT100->(DbCloseArea())
							EndIf
							TcQuery cQuery NEW Alias "ADMT100"
			
							nVlrnflc := ADMT100->D1_TOTAL //Valor convertido taxa da data de emissao de cada nota encontrada
					
							For nPc2:=1 To Len(aCols)				
								If aCols[nPc2] [LEN(aHeader) + 1] == .F.					
									If cCodpcnf = gdFieldGet( "D1_PEDIDO" , nPc2 ) .AND. cItepcnf = gdFieldGet( "D1_ITEMPC" , nPc2 )
										nVlrttnf += gdFieldGet( "D1_TOTAL" , nPc2 )
									EndIf				
								EndIF  			
							Next
							
							nVlrttnf := iif(nVlrDlr=0,0,nVlrttnf / nVlrDlr) // Valor convertido taxa da data de emissao da nota atual

						Else

							cQuery := " SELECT D1_FILIAL, D1_PEDIDO, D1_ITEMPC, ISNULL(SUM(D1_TOTAL-D1_VALDEV),0) D1_TOTAL "
							cQuery += " FROM "+RetSqlName("SD1")+" SD1 (NOLOCK) "
							cQuery += " INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON SD1.D1_DOC = SF1.F1_DOC AND SD1.D1_SERIE = SF1.F1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SF1.F1_LOJA " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli
							cQuery += " WHERE D1_FILIAL = '"+FWxFilial("SD1")+"' "
							cQuery += " AND D1_PEDIDO = '"+cCodpcnf+"' AND D1_ITEMPC = '"+cItepcnf+"' "
//							cQuery += " AND D1_TES <> ' ' " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli
							cQuery += " AND SF1.F1_STATUS <> '' " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli
							cQuery += " AND SF1.D_E_L_E_T_ = '' " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli
							cQuery += " AND SD1.D_E_L_E_T_ = '' "
							cQuery += " GROUP BY F1_STATUS,D1_FILIAL, D1_PEDIDO, D1_ITEMPC " // por Adriana em 03/06/2020 - solicitacao do Fernando Sigoli
				
							If Select("ADMT100") > 0
								ADMT100->(DbCloseArea())
							EndIf
							TcQuery cQuery NEW Alias "ADMT100"
			
							nVlrnflc := ADMT100->D1_TOTAL
					
							For nPc2:=1 To Len(aCols)				
								If aCols[nPc2] [LEN(aHeader) + 1] == .F.					
									If cCodpcnf = gdFieldGet( "D1_PEDIDO" , nPc2 ) .AND. cItepcnf = gdFieldGet( "D1_ITEMPC" , nPc2 )
										nVlrttnf += gdFieldGet( "D1_TOTAL" , nPc2 )
									EndIf				
								EndIF  			
							Next
								
						Endif

						nTotPed := SC7->C7_TOTAL
							
						//Inicio 1- Fernando Sigoli 12/03/2019- Chamado: 047820
						cErroTot := "Incluindo esse Lançamento, o valor das entradas, será maior que o valor do item do Pedido "+Alltrim(cCodpcnf)+"-"+Alltrim(cItepcnf)+STR_LF+STR_LF+;
									"Documentos já Lançados"+chr(9)+cSimbMoe+Transform(nVlrnflc, PesqPict("SC7","C7_TOTAL"))+STR_LF+;
									"Documento Atual"+chr(9)+cSimbMoe+Transform(nVlrttnf, PesqPict("SC7","C7_TOTAL"))+STR_LF+;
									"Total Documentos"+chr(9)+cSimbMoe+Transform(nVlrnflc+nVlrttnf, PesqPict("SC7","C7_TOTAL"))+STR_LF+STR_LF+;
									"Total Item Pedido"+chr(9)+chr(9)+cSimbMoe+Transform(nTotPed, PesqPict("SC7","C7_TOTAL"))
							
						If Posicione("SB1",1,xFilial("SB1")+cProd,"B1_GRUPO") $ GETMV("MV_#GRUPOS",,"9028/") //Grupo 9028 cozinha  
								
							If Round( (nVlrttnf + nVlrnflc) ,2) > ROUND(nTotPed + (nTotPed * (GETMV("MV_PERARE") / 100) ),2) 
								_lOk := .f.
								nVlrttnf := 0
								Aviso("MT140LOK-19", cErroTot, { "&Retorna" },,"Valor Entradas > Valor Pedido "+STR_LF+"% Tolerancia: "+STR(GETMV("MV_PERARE"),3) )
							EndIf

						EndIf
							
						If Posicione("SB1",1,xFilial("SB1")+cProd,"B1_GRUPO") $ GETMV("MV_#TOLQTD",,"9006/9007/9044/9045") //Grupo de embalagens
						
							If Round( (nVlrttnf + nVlrnflc) ,2) > ROUND(nTotPed + (nTotPed * (GETMV("MV_PERCEMB") / 100) ),2) 
								_lOk := .f.
								nVlrttnf := 0
								Aviso("MT140LOK-20", cErroTot, { "&Retorna" },,"Valor Entradas > Valor Pedido "+STR_LF+"% Tolerancia: "+STR(GETMV("MV_PERCEMB"),3))
							EndIf

						EndIf
		
						If FWxFilial("SF1") == GetMV("MV_#TOLFIL",,"03")               .AND. ;
							SB1->B1_GRUPO $ GETMV("MV_#GRPEDR",,"9013/9015/9016/9017") .AND. ; //William Costa 11/03/2019 chamado 047734
							AllTrim(cUM) <> 'UN'                                       .AND. ;
							AllTrim(cUM) <> 'PC'

							If Round( (nVlrttnf + nVlrnflc) ,2) > ROUND(nTotPed + (nTotPed * (IIF(ALLTRIM(cProd) $ GETMV("MV_PEDAREI"), GETMV("MV_PERARE") /*10%*/, GETMV("MV_PERCACO") /*3%*/) / 100) ),2) 
								_lOk := .f.
								nVlrttnf := 0
								Aviso("MT140LOK-21", cErroTot, { "&Retorna" },,"Valor Entradas > Valor Pedido "+STR_LF+"% Tolerancia: "+STR((IIF(ALLTRIM(cProd) $ GETMV("MV_PEDAREI"), ;
									GETMV("MV_PERARE") /*10%*/, GETMV("MV_PERCACO") /*3%*/)),3) )
							EndIf

						EndIf

						//todos os demais grupos
						
						If Round( (nVlrttnf + nVlrnflc) ,2) > Round( (nTotPed + GETMV("MV_#VLTOTN")) ,2)
							_lOk := .f.
							nVlrttnf := 0
							Aviso("MT140LOK-22", cErroTot, { "&Retorna" },,"Valor Entradas > Valor Pedido "+STR_LF+"Tolerancia: "+STR(GETMV("MV_#VLTOTN"),5,2) )
						EndIf
						
					    //Fim 1- Fernando Sigoli 12/03/2019- Chamado: 047820
					Endif		

				EndIf	

			Next
			//Fim trecho revisado - por Adriana em 03/06/2020 - chamado 057598 

		EndIf

	EndIf

	RestArea( aAreaSC7 )
	RestArea( aAreaSB1 )

Return _lOk
