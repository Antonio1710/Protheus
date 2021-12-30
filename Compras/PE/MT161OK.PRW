#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function nomeFunction
	Ponto de entrada usado para validar as propostas dos fornecedores no momento da gravação da análise da cotação. 
	Se .T. finaliza o processo. Se .F., interrompe o processo. 
	@type  Function
	@author Fernando Macieira
	@since 22/01/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 65456 - Fernando Macieira - 29/12/2021 - Cotação diferentes com a mesma SC gerando compras indevidas
/*/
User Function MT161OK()

	Local lMT161Ok   := .t.
	Local aPropostas := PARAMIXB[1] // Array contendo todos os dados da proposta da cotação
	Local cTpDoc     := PARAMIXB[2] // Tipo do documento
	Local lSldAtv    := GetMV("MV_#PRJSLD",,".T.")
	Local nTtPrj     := 0
	Local nSldPrj    := 0
	Local cCodPrj    := ""
	Local nTotCot    := 0
	Local cItemCta   := ""
	Local aAprov     := {}
	Local aAreaSC1   := SC1->( GetArea() )
	Local aAreaSC8   := SC8->( GetArea() )
	Local aAreaAF8   := AF8->( GetArea() )
	Local aArea      := GetArea()
	Local lOutraC1   := .f.
	Local cNumOutC8  := ""

	// Projetos Investimentos
	For nY := 1 To Len(aPropostas)
		For nX := 1 To Len(aPropostas[nY])
			
			If Len(aPropostas[nY][nX][2]) > 0
				
				If aPropostas[nY][nx][2][1][1] // Proposta/Fornecedor escolhido

					// Posiciono no registro da cotacao para buscar o codigo do projeto
					nRecno := aPropostas[nY][nx][2][1][9]
					SC8->(dbGoTo(nRecno))
					
					cCodPrj := SC8->C8_PROJETO
					
					// Se cotação possui projeto
					If !Empty(cCodPrj)
			
						// Controle Saldo Projeto ativo
						If lSldAtv
				
							AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
							AF8->( dbSeek(FWxFilial("AF8")+cCodPrj) )
				
							// Consiste apenas projetos que possuem valor
							If AF8->AF8_XVALOR > 0
					
								nTtPrj  := UpVlrPrj()
								nSldPrj := u_ADCOM017P(cCodPrj)
					
								// Consiste saldo informado na cotacao x saldo do projeto (AF8)
								If nTtPrj > nSldPrj
									
									lMT161Ok := .f.
									
									Aviso(	"MT161OK-01",;
									"Saldo do projeto n. " + AllTrim(cCodPrj) + " insuficiente! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
									"Fornecedor: " + SC8->C8_FORNOME + chr(13) + chr(10) +;
									"[Cotação] Total: " + Transform(nTtPrj, PesqPict("SC8","C8_TOTAL")) + chr(13) + chr(10) +;
									"[PRJ] Saldo: " + Transform(nSldPrj, PesqPict("SC8","C8_TOTAL")),;
									{ "&Retorna" },,;
									"Projeto sem saldo" )
	
									Exit
									
								EndIf
					
							EndIf
				
						EndIf
			
					EndIf

					// FWNM - TI - 23/01/2019 - pedidos sem alcada
					If lMT161Ok

						// Total da cotacao vencedora/escolhida
						nTotCot := UpTotCot()
						
						cItemCta := Posicione("SC1",1,SC8->C8_FILIAL+SC8->C8_NUMSC,"C1_ITEMCTA")

						// Obtem os aprovadores para os centros de custo
						aAprov	:= u_GetAprov( SC8->C8_CC, cItemCta, nTotCot )
		
						If Len(aAprov)==0

							lMT161Ok := .f.
							
							Aviso(	"MT161OK-02",;
							"Não foi localizado controle de alçada para o centro de custo / Item Contábil! Pedido de compras não será gerado...",;
							{ "&Retorna" },,;
							"CCusto/ItemCta: " + AllTrim(SC8->C8_CC) + "/" + AllTrim(cItemCta) )
							
							Exit

						EndIf						
					
					EndIf

					// @history ticket 65456 - Fernando Macieira - 29/12/2021 - Cotação diferentes com a mesma SC gerando compras indevidas
					If lMT161Ok
						lOutraC1 := ChkOutSC8(@cNumOutC8)
						If lOutraC1
							lMT161Ok := .f.
							msgAlert("Já existe outra cotação n. " + cNumOutC8 + " para a mesma SC n. " + SC8->C8_NUMSC + " para o mesmo produto " + SC8->C8_PRODUTO + " nesta filial! Verifique...")
							Exit
						EndIf
					EndIf
					//
				
				EndIf
			
			EndIf
			
		Next nX
		
		If !lMT161Ok
			Exit
		EndIf
		
	Next nY


	// FWNM - TI - 23/01/2019 - pedidos sem alcada - OTIMIZACAO
	/*
	If lMT161Ok

		For nY := 1 To Len(aPropostas)
			For nX := 1 To Len(aPropostas[nY])
				
				If Len(aPropostas[nY][nX][2]) > 0
					
					If aPropostas[nY][nx][2][1][1] // Proposta/Fornecedor escolhido
	
						// Posiciono no registro da cotacao para buscar o codigo do projeto
						nRecno := aPropostas[nY][nx][2][1][9]
						SC8->(dbGoTo(nRecno))
						
						// Total da cotacao vencedora/escolhida
						nTotCot := UpTotCot()
						
						cItemCta := Posicione("SC1",1,SC8->C8_FILIAL+SC8->C8_NUMSC,"C1_ITEMCTA")

						// Obtem os aprovadores para os centros de custo
						aAprov	:= u_GetAprov( SC8->C8_CC, cItemCta, nTotCot )
		
						If Len(aAprov)==0

							lMT161Ok := .f.
							
							Aviso(	"MT161OK-02",;
							"Não foi localizado controle de alçada para o centro de custo / Item Contábil! Pedido de compras não será gerado...",;
							{ "&Retorna" },,;
							"CCusto/ItemCta: " + AllTrim(SC8->C8_CC) + "/" + AllTrim(cItemCta) )
							
							Exit

						EndIf						
										
					EndIf
						
				EndIf
				
			Next nX
			
			If !lMT161Ok
				Exit
			EndIf
			
		Next nY

	EndIf
	*/
	
	RestArea( aAreaAF8 )
	RestArea( aAreaSC8 )
	RestArea( aAreaSC1 )
	RestArea( aArea )

Return lMT161Ok

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT161OK   ºAutor  ³Fernando Macieira   º Data ³  22/01/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para carregar o valor do projeto contido na cotacao º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function UpVlrPrj()

	Local nVlrPrj := 0
	Local cQuery  := ""
	
	// Totaliza COTACAO (SC8)
	If Select("WorkSC8") > 0
		WorkSC8->( dbCloseArea() )
	EndIf
	
	cQuery := " SELECT ISNULL(SUM(SC8.C8_TOTAL),0) AS TOTAL "
	cQuery += " FROM " + RetSqlName( "SC8" ) + " SC8 (NOLOCK) "
	cQuery += " WHERE SC8.C8_FILIAL = '" + SC8->C8_FILIAL + "' "
	cQuery += " AND SC8.C8_NUM = '" + SC8->C8_NUM + "' "
	cQuery += " AND SC8.C8_FORNECE = '" + SC8->C8_FORNECE + "' "
	cQuery += " AND SC8.C8_LOJA = '" + SC8->C8_LOJA + "' "
	cQuery += " AND SC8.C8_PROJETO = '" + SC8->C8_PROJETO + "' "
	cQuery += " AND SC8.D_E_L_E_T_ = ' ' "
	
	tcQuery cQuery new Alias "WorkSC8"
	
	aTamSX3	:= TamSX3("C8_TOTAL")
	tcSetField("WorkSC8", "TOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	
	nVlrPrj := WorkSC8->TOTAL
	
	WorkSC8->( dbCloseArea() )

Return nVlrPrj

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT161OK   ºAutor  ³Fernando Macieira   º Data ³  22/01/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para carregar o valor total da cotacao              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function UpTotCot()

	Local nTotCot := 0
	Local cQuery  := ""
	
	// Totaliza COTACAO (SC8)
	If Select("WorkSC8") > 0
		WorkSC8->( dbCloseArea() )
	EndIf
	
	cQuery := " SELECT ISNULL(SUM(SC8.C8_TOTAL),0) AS TOTAL "
	cQuery += " FROM " + RetSqlName( "SC8" ) + " SC8 (NOLOCK) "
	cQuery += " WHERE SC8.C8_FILIAL = '" + SC8->C8_FILIAL + "' "
	cQuery += " AND SC8.C8_NUM = '" + SC8->C8_NUM + "' "
	cQuery += " AND SC8.C8_FORNECE = '" + SC8->C8_FORNECE + "' "
	cQuery += " AND SC8.C8_LOJA = '" + SC8->C8_LOJA + "' "
	cQuery += " AND SC8.D_E_L_E_T_ = ' ' "
	
	tcQuery cQuery new Alias "WorkSC8"
	
	aTamSX3	:= TamSX3("C8_TOTAL")
	tcSetField("WorkSC8", "TOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	
	nTotCot := WorkSC8->TOTAL
	
	WorkSC8->( dbCloseArea() )

Return nTotCot

/*/{Protheus.doc} nomeStaticFunction
	Outra cotação com a mesma SC e Produto
	@type  Static Function
	@author FWNM
	@since 29/12/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ChkOutSC8(cNumOutC8)

	Local lOutra := .f.
    Local cQuery := ""

    If Select("WorkC8") > 0
        WorkC8->( dbCloseArea() )
    EndIf

    cQuery := " SELECT DISTINCT C8_FILIAL, C8_NUM, C8_PRODUTO
    cQuery += " FROM " + RetSqlName("SC8") + " SC8 (NOLOCK)
    cQuery += " WHERE C8_FILIAL='"+FWxFilial("SC8")+"' 
    cQuery += " AND C8_NUM<>'"+SC8->C8_NUM+"' 
	cQuery += " AND C8_NUMSC='"+SC8->C8_NUMSC+"' 
    cQuery += " AND C8_PRODUTO='"+SC8->C8_PRODUTO+"' 
    cQuery += " AND SC8.D_E_L_E_T_=''

    tcQuery cQuery New Alias "WorkC8"

    WorkC8->( dbGoTop() )
    If WorkC8->( !EOF() )
        cNumOutC8 := WorkC8->C8_NUM
        lOutra := .T.
    EndIf

    If Select("WorkC8") > 0
        WorkC8->( dbCloseArea() )
    EndIf
	
Return lOutra
