#include "protheus.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT150OK   ºAutor  ³Fernando Macieira   º Data ³  09/18/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada executado na atualizacao da cotacao.      º±±
±±º          ³ Visa garantir o preenchimento do campo C8_PROJETO.         º±±
±±º          ³ Chamado n. 043947 - Reginaldo Fagian                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºChamado   ³ 046284 - fwnm - 08/01/2019 - Novas regras alteracao valor  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºChamado   ³ TI -     fwnm - 26/03/2019 - Permitir exclusao prj invest  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT150OK()

	Local i
	Local cPrj    := ""
	Local cCC     := ""
	Local nTtPrj  := ""
	Local cNumSC  := ""
	Local cItemSC := ""
	Local lRetorno := .t.
	
	Local lSldAtv   := GetMV("MV_#PRJSLD",,".T.")
	Local cFasePrj  := GetMV("MV_PRJINIC",,"05")
	
	// Chamado n. 046284
	Local cFaseRej := GetMV("MV_#FASREJ",,"01")
	Local cFaseApr := GetMV("MV_#FASEOK",,"03")
	//  
	
	// Chamado n. TI -     fwnm - 26/03/2019 - Permitir exclusao prj invest
	Local nOpcx := PARAMIXB[1]
	
	/*
	Numero da opção selecionada.
	2- Novo Participante
	3- Atualizar
	4- Proposta
	5- Excluir
	*/
	
	If nOpcx == 5 // Excluir
		//msginfo("opcao 5 = excluir")
		Return lRetorno
	EndIf
	//
	
	For i:=1 to Len(aCols)
		
		cPrj    := gdFieldGet("C8_PROJETO", i)
		cCC     := gdFieldGet("C8_CC", i)
		nTtPrj  := gdFieldGet("C8_TOTAL", i)
		cNumSC  := gdFieldGet("C8_NUMSC", i)
		cItemSC := gdFieldGet("C8_ITEMSC", i)
		
		//Consiste Projeto Encerrado
		dbSelectArea("AF8")
		dbSetOrder(1)
		If dbseek(FWxFilial("AF8")+cPrj)
			If AllTrim(AF8->AF8_ENCPRJ) == "1"
				MsgAlert("O Projeto "+cPrj+" se encontra ENCERRADO e nao aceita mais lancamentos.")
				lRetorno := .f.
			EndIf
		EndIf
		
		// Consistencia para projetos ja existentes nao sofrerem problemas com a falta do saldo, conceito implementado a partir de JAN/2018
		//		If DtoS(AF8->AF8_DATA) <= "20180101"
		If AF8->AF8_XVALOR == 0
			Return lRetorno
			lRetorno := .t.
		EndIf
		
		// Consiste qdo prj de investimento
		If lRetorno
			
			lPrjInv := Left(AllTrim(cCC),1) == "9"
			
			// qdo prj investimento
			If lPrjInv .and. !Alltrim(cCC) $ GetMV("MV_#CCPADR")
				
				If Empty(cPrj)
					lRetorno := .f.
					
					Aviso(	"MT150OK-01",;
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
						
						Aviso(	"MT150OK-02",;
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
						
						Aviso(	"MT150OK-03",;
						"Este projeto n. " + AllTrim(cPrj) + " não pertence a esta filial! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
						"Filial/Planta: " + cFilAnt + chr(13) + chr(10) +;
						"Projeto/Planta: " + Left(AllTrim(cPrj),2),;
						{ "&Retorna" },,;
						"Projeto x Filial/Planta" )
						
					EndIf
					
				EndIf
				
				// Consiste datas previstas do projeto (AF8) x data de digitação oriunda do servidor do documento
				If lRetorno
					
					dDtDig := msDate()
					
					If dDtDig < AF8->AF8_START .or. dDtDig > AF8->AF8_FINISH
						
						lRetorno := .f.
						
						Aviso(	"MT150OK-04",;
						"Vigêcia do projeto n. " + AllTrim(cPrj) + " está fora! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
						"Data Digitação: " + DtoC(dDtDig) + chr(13) + chr(10) +;
						"Início-Fim Projeto: " + DtoC(AF8->AF8_START) + " - " + DtoC(AF8->AF8_FINISH),;
						{ "&Retorna" },,;
						"Vigência do Projeto" )
						
					EndIf
					
				EndIf
				
				// Consiste fase do projeto para checar se esta na central de aprovacao
				If lRetorno
					
					// If AllTrim(cFasePrj) == AllTrim(AF8->AF8_FASE)// Chamado n. 046284
					If AllTrim(AF8->AF8_FASE) <> AllTrim(cFaseApr) // Se fase diferente de aprovada // Chamado n. 046284

						lRetorno := .f.
						
						Aviso(	"MT150OK-05",;
						"Projeto n. " + AllTrim(cPrj) + " não foi aprovado na Central de Aprovação! " + chr(13) + chr(10) + "Uso ainda não permitido..." + chr(13) + chr(10) + ;
						"",;
						{ "&Retorna" },,;
						"Projeto não aprovado" )
						
					EndIf
				EndIf
				
			Else
				
				If !Empty(cPrj)
					lRetorno := .f.
					
					Aviso(	"MT150OK-06",;
					"Centro de Custo: " + cCC + "." + Chr(13) + Chr(10) +;
					"Não permitido o preenchimento do Projeto.",;
					{ "&Retorna" },,;
					"Não permitido informar projeto para CC que não é investimento" )
				EndIf
				
			EndIf
			
		EndIf
		
	Next i
	
	// consiste valor/saldo
	// Totaliza projetos informados nos itens para confrontar com o saldo do mesmo
	If lRetorno
		
		// Controle Saldo Projeto ativo
		If lSldAtv
			
			
			aTtPrj := {} // armazenará os dados do projeto para totalizar e consistir
			
			For i:=1 to Len(aCols)
				
				If !gdDeleted(i)
					
					cPrj    := gdFieldGet("C8_PROJETO", i)
					
					If !Empty(cPrj)
						
						// Projeto Investimento
						cCC     := gdFieldGet("C8_CC", i)
						lPrjInv := Left(AllTrim(cCC),1) == "9"
						
						If lPrjInv .and. !Alltrim(cCC) $ GetMV("MV_#CCPADR")
							
							nTt     := gdFieldGet("C8_TOTAL", i)
							nDesc   := 0
							
							// Valor do projeto do item
							nTtPrj := (nTt - nDesc)
							
							aAdd( aTtPrj, {	cPrj,;
							nTtPrj } )
							
						EndIf
						
					EndIf
					
				EndIf
				
			Next i
			
			// Consiste total projeto
			aSort( aTtPrj,,, { |x,y| x[1] < y[1] } )
			
			cColsPrj := ""
			nColsTot := 0
			
			For y:=1 to Len(aTtPrj)
				
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
								nSldPrj := u_ADCOM017P(cColsPrj)
								
								If nColsTot > nSldPrj
									
									lRetorno := .f.
									
									Aviso(	"MT150OK-07",;
									"Saldo do projeto n. " + AllTrim(cColsPrj) + " insuficiente! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
									"[Cotação] Total itens: " + Transform(nColsTot, PesqPict("SC8","C8_TOTAL")) + chr(13) + chr(10) +;
									"[Projeto] Saldo: " + Transform(nSldPrj, PesqPict("SC8","C8_TOTAL")),;
									{ "&Retorna" },,;
									"Projeto sem saldo" )
									
								Else
									// zero variaveis para proximo projeto
									cColsPrj := aTtPrj[y,1]
									nColsTot := aTtPrj[y,2]
									
								EndIf
								
							EndIf
							
						EndIf
						
					EndIf
					
				EndIf
				
			Next y
			
			// Consisto o último projeto do acols - NÃO RETIRAR !!!
			If lRetorno
				
				AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
				If AF8->( dbSeek(xFilial("AF8")+cColsPrj) )
					
					// Consiste apenas projetos que possuem valor
					If AF8->AF8_XVALOR > 0
						
						// Consiste saldo informado no documento de entrada x saldo do projeto (AF8)
						nSldPrj := u_ADCOM017P(cColsPrj)
						
						If nColsTot > nSldPrj
							
							lRetorno := .f.
							
							Aviso(	"MT150OK-09",;
							"Saldo do projeto n. " + AllTrim(cColsPrj) + " insuficiente! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
							"[Cotação] Total itens: " + Transform(nColsTot, PesqPict("SC8","C8_TOTAL")) + chr(13) + chr(10) +;
							"[Projeto] Saldo: " + Transform(nSldPrj, PesqPict("SC8","C8_TOTAL")),;
							{ "&Retorna" },,;
							"Projeto sem saldo" )
							
						EndIf
						
					EndIf
					
				EndIf
				
			EndIf
			
		EndIf
		
	EndIf

Return lRetorno