#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function ADCOM017P
	Funcao para carregar o consumo e/ou saldo do projeto. AF8 = Compartilhada = Pode ser utilizada em qq filial
	Ajustar querys contidas nos fontes ADPMS005P e ADMNT008R sempre que algum filtro das querys abaixo forem modificadas
	@type  Function
	@author Fernando Macieira
	@since 24/11/2017
	@version 01
	@history Chamado 046075 - William Costa     - 27/12/2018 - Ajustado para nao ver pedidos rejeitados
	@history Chamado TI     - FWNM              - 25/02/2019 - Consumo projeto errado devido elimina residuos e valor total da NF
	@history Chamado 050791 - FWNM              - 30/07/2019 - Considerar saldo pedido quando entrega parcial do item. Exemplo: C7_QUJE < QUANT e C7_QUJE > 0 e C7_ENCER<>E
	@history Chamado 051453 - Adriana Oliveira  - 03/09/2019 - Considerar impostos de importacao no consumo do projeto 
	@history Chamado 052816 - FWNM              - 21/10/2019 - Controle projetos
	@history Chamado 054064 - FWNM              - 11/12/2019 - OS 055455 || CONTROLADORIA || DAIANE || (16) || SALDO DE PROJETO
	@history Chamado TI     - William Costa     - 17/12/2019 - Identificado erro de divisão por zero no DBACESS, foi ajustado a query para verficar se o registro de quantidade for 0 vira 1 se não carrega o que vem da quantidade
	@history Chamado 059436 - FWNM              - 07/07/2020 - || OS 060933 || CONTROLADORIA || DAIANE || 3549 || PROJETO NEGATIVO
	@history Ticket 313     - FWNM              - 21/08/2020 - Considerar desconto do pedido de compra, campo C7_VLDESC
	@history Ticket 352     - FWNM              - 21/08/2020 - Criar inteligência para não considerar saldo duplicado no momento da classificação
	@history Ticket 2481 - FWNM - 29/09/2020 - PROJETO 021906005 - [IMPLEMENTAÇÃO] DESOSSADORA DE COXA E SOBRECOXA - consumo de projeto
/*/
//User Function ADCOM017P(cCodPrj,cOrigem,cPCItemKey,cDespesas)
User Function ADCOM017P(cCodPrj,cOrigem,cPCItemKey,cDespesas,cNFKey) // @history Ticket 352     - FWNM              - 21/08/2020 - Criar inteligência para não considerar saldo duplicado no momento da classificação

	Local nVlrPrj := 0
	Local nSldPrj := 0
	Local cQuery  := ""
	Local aAreaATU := GetArea()
	Local nToTPrj    := 0
	Local nPCTotPrj  := 0
	Local nPC2TotPrj := 0 // FWNM - 25/02/2019
	Local nPC3TotPrj := 0 // FWNM - 30/07/2019 - Chamado 050791
	Local nPCDescont := 0 // @history Ticket 313     - FWNM              - 21/08/2020 - Considerar desconto do pedido de compra, campo C7_VLDESC
	Local nNFITotPrj := 0 // Adriana - 03/09/2019 - Chamado 051453
	Local nNFTotPrj  := 0
	Local nDevTotPrj := 0
	Local nSATotPrj  := 0
	Local aDespesas  := {}
	Local nNFIIPI    := 0
	Local nNFIFrete  := 0
	Local nNFIDespes := 0
	Local nNFISeguro := 0
	Local nNFIICMS   := 0
	Local nNFIPIS    := 0
	Local nNFICOF    := 0
	Local nNFIICMSST := 0
	Local nNFIDesc   := 0
	Local nNFTIPI    := 0
	Local nNFTFrete  := 0
	Local nNFTDespes := 0
	Local nNFTSeguro := 0
	Local nNFTICMSST := 0
	Local nNFTDesc   := 0
	Local nPCTIPI    := 0
	Local nPCTFrete  := 0
	Local nPCTDespes := 0
	Local nPCTSeguro := 0
	Local nPCTICMSST := 0
	Local nPCTDesc   := 0
	Local nPC2TIPI   := 0
	Local nPC2TFrete := 0
	Local nPC2TDespes:= 0
	Local nPC2TSeguro:= 0
	Local nPC2TICMSST:= 0
	Local nPC2TDesc  := 0
	Local nPC3TIPI    := 0
	Local nPC3TFrete  := 0
	Local nPC3TDespes := 0
	Local nPC3TSeguro := 0
	Local nPC3TICMSST := 0
	Local nPC3TDesc   := 0
	
	Default cCodPrj    := ""
	Default cOrigem    := ""
	Default cPCItemKey := ""                                        
	Default cNFKey     := "" // @history Ticket 352     - FWNM              - 21/08/2020 - Criar inteligência para não considerar saldo duplicado no momento da classificação
	Default cDespesas  := "" // Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 23/10/2019                                       

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	If !Empty(cCodPrj)
		
		// DEBUG
		//cCodPrj := "021906003" 
		//
		
		// Busca Valor Prj
		AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
		If AF8->( dbSeek(xFilial("AF8")+cCodPrj) )
			
			If AF8->(FieldPos("AF8_XVALOR")) > 0
				nVlrPrj := AF8->AF8_XVALOR
				
			Else
				If AllTrim(cOrigem) <> "BROWSE"
					Aviso(	"ADCOM017P-02",;
					"Projeto não possui campo para controle do valor... Contate o administrador do Protheus para criá-lo!",;
					{ "&Retorna" },,;
					"Campo [AF8_XVALOR - N - 18 - 2] editável somente na inclusão" )
				EndIf
				
			EndIf
			
		EndIf

		// Busca Consumo Prj
	
		////////////////////////////////////////////////////////////////////////////////////////////////////
		// NOTA FISCAL CLASSIFICADA - EXTERIOR
		////////////////////////////////////////////////////////////////////////////////////////////////////
		If Select("WorkPrj") > 0
			WorkPrj->( dbCloseArea() )
		EndIf
	
		If cDespesas == "DESPESAS"
			cQuery := " SELECT ISNULL(SUM(D1_TOTAL),0) AS TOTAL, "
			cQuery += "        ISNULL(SUM(D1_VALIPI),0) AS IPI, "
			cQuery += "        ISNULL(SUM(D1_VALFRE),0) AS FRETE, "
			cQuery += "        ISNULL(SUM(D1_DESPESA),0) AS DESPESA, "
			cQuery += "        ISNULL(SUM(D1_SEGURO),0) AS SEGURO, "
			cQuery += "        ISNULL(SUM(D1_VALICM),0) AS ICMS, "
			cQuery += "        ISNULL(SUM(D1_VALIMP5),0) AS COFINS, "
			cQuery += "        ISNULL(SUM(D1_VALIMP6),0) AS PIS, "
			cQuery += "        ISNULL(SUM(D1_ICMSRET),0) AS ICMSST, "
			cQuery += "        ISNULL(SUM(D1_VALDESC),0) AS DESCONTO "
		Else
			cQuery := " SELECT ISNULL(SUM(D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_VALICM+D1_VALIMP5+D1_VALIMP6+D1_ICMSRET-D1_VALDESC),0) AS TOTAL "
		EndIf
		
		// @history Ticket 352     - FWNM              - 24/08/2020 - Criar inteligência para não considerar saldo duplicado no momento da classificação
		// NOTAS CLASSIFICADAS - DEVIDO SAG E CENTRAL XML GRAVAREM PRE-NOTA COM TES PREENCHIDO

		//cQuery += " FROM " + RetSqlName( "SD1" ) + " SD1 (NOLOCK), " + RetSqlName("SF4") + " SF4 (NOLOCK) "
		cQuery += " FROM " + RetSqlName( "SD1" ) + " SD1 (NOLOCK), " + RetSqlName("SF4") + " SF4 (NOLOCK), " + RetSqlName("SF1") + " SF1 (NOLOCK)

		//cQuery += " WHERE F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_TIPO=D1_TIPO AND F1_FORNECE=D1_FORNECE AND F1_LOJA=D1_LOJA AND SF1.D_E_L_E_T_='' AND F1_STATUS='A' // Ticket 2481 - FWNM - 29/09/2020 - PROJETO 021906005 - [IMPLEMENTAÇÃO] DESOSSADORA DE COXA E SOBRECOXA - consumo de projeto
		cQuery += " WHERE F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_TIPO=D1_TIPO AND F1_FORNECE=D1_FORNECE AND F1_LOJA=D1_LOJA AND SF1.D_E_L_E_T_=''

		//cQuery += " WHERE D1_TES=F4_CODIGO 
		cQuery += " AND D1_TES=F4_CODIGO 
		// 

		cQuery += " AND SD1.D1_FILIAL BETWEEN '' AND 'ZZ' "
		
		// @history Ticket 352     - FWNM              - 21/08/2020 - Criar inteligência para não considerar saldo duplicado no momento da classificação
		//cQuery += " AND (SD1.D1_FILIAL + SD1.D1_DOC + SD1.D1_SERIE + SD1.D1_TIPO + SD1.D1_FORNECE + SD1.D1_LOJA + SD1.D1_COD + SD1.D1_ITEM) NOT IN " + FormatIn(cNFKey,"|")
		cQuery += " AND (SD1.D1_FILIAL + SD1.D1_DOC + SD1.D1_SERIE + SD1.D1_TIPO + SD1.D1_FORNECE + SD1.D1_LOJA) NOT IN " + FormatIn(cNFKey,"|")

		// CLASSIFICADAS
		// Inibido pois qdo a classificação é estornada, o PC continua com o C7_QUJE preenchido
		//cQuery += " AND SD1.D1_TES <> '' " // Chamado n. 059436 || OS 060933 || CONTROLADORIA || DAIANE || 3549 || PROJETO NEGATIVO - FWNM - 07/07/2020
		
		cQuery += " AND SD1.D1_PROJETO = '" + cCodPrj + "' "
		cQuery += " AND SD1.D1_CF LIKE '3%' "
		cQuery += " AND SD1.D_E_L_E_T_ = '' "

		cQuery += " AND F4_FILIAL='"+xFilial("SF4")+"' "
		cQuery += " AND F4_DUPLIC='S' "
		cQuery += " AND SF4.D_E_L_E_T_ = '' "
		
		tcQuery cQuery new Alias "WorkPRJ"
		
		aTamSX3	:= TamSX3("D1_TOTAL")
		tcSetField("WorkPRJ", "TOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2])

	    nNFITotPrj := WorkPRJ->TOTAL

		If cDespesas == "DESPESAS"

			aTamSX3	:= TamSX3("D1_VALIPI")
			tcSetField("WorkPRJ", "IPI", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("D1_VALFRE")
			tcSetField("WorkPRJ", "FRETE", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("D1_DESPESA")
			tcSetField("WorkPRJ", "DESPESA", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("D1_SEGURO")
			tcSetField("WorkPRJ", "SEGURO", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("D1_VALICM")
			tcSetField("WorkPRJ", "ICMS", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("D1_VALIMP5")
			tcSetField("WorkPRJ", "COFINS", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("D1_VALIMP6")
			tcSetField("WorkPRJ", "PIS", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("D1_ICMSRET")
			tcSetField("WorkPRJ", "ICMSST", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("D1_VALDESC")
			tcSetField("WorkPRJ", "DESCONTO", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			nNFIIPI    := WorkPRJ->IPI
			nNFIFrete  := WorkPRJ->FRETE
			nNFIDespes := WorkPRJ->DESPESA
			nNFISeguro := WorkPRJ->SEGURO
			nNFIICMS   := WorkPRJ->ICMS
			nNFIPIS    := WorkPRJ->PIS
			nNFICOF    := WorkPRJ->COFINS
			nNFIICMSST := WorkPRJ->ICMSST
			nNFIDesc   := WorkPRJ->DESCONTO
		
	    EndIf
	    
		////////////////////////////////////////////////////////////////////////////////////////////////////
		// NOTA FISCAL CLASSIFICADA - NACIONAL
		////////////////////////////////////////////////////////////////////////////////////////////////////
		If Select("WorkPrj") > 0
			WorkPrj->( dbCloseArea() )
		EndIf
	    
		If cDespesas == "DESPESAS"
			cQuery := " SELECT ISNULL(SUM(D1_TOTAL),0) AS TOTAL, 
			cQuery += "        ISNULL(SUM(D1_VALIPI),0) AS IPI, 
			cQuery += "        ISNULL(SUM(D1_VALFRE),0) AS FRETE, 
			cQuery += "        ISNULL(SUM(D1_DESPESA),0) AS DESPESA, 
			cQuery += "        ISNULL(SUM(D1_SEGURO),0) AS SEGURO, 
			cQuery += "        ISNULL(SUM(D1_ICMSRET),0) AS ICMSST, 
			cQuery += "        ISNULL(SUM(D1_VALDESC),0) AS DESCONTO 
		Else
			cQuery := " SELECT ISNULL(SUM(D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_ICMSRET-D1_VALDESC),0) AS TOTAL 
		EndIf

		// @history Ticket 352     - FWNM              - 24/08/2020 - Criar inteligência para não considerar saldo duplicado no momento da classificação
		// NOTAS CLASSIFICADAS - DEVIDO SAG E CENTRAL XML GRAVAREM PRE-NOTA COM TES PREENCHIDO

		//cQuery += " FROM " + RetSqlName( "SD1" ) + " SD1 (NOLOCK), " + RetSqlName("SF4") + " SF4 (NOLOCK) 
		cQuery += " FROM " + RetSqlName( "SD1" ) + " SD1 (NOLOCK), " + RetSqlName("SF4") + " SF4 (NOLOCK), " + RetSqlName("SF1") + " SF1 (NOLOCK)

		//cQuery += " WHERE F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_TIPO=D1_TIPO AND F1_FORNECE=D1_FORNECE AND F1_LOJA=D1_LOJA AND SF1.D_E_L_E_T_='' AND F1_STATUS='A' // Ticket 2481 - FWNM - 29/09/2020 - PROJETO 021906005 - [IMPLEMENTAÇÃO] DESOSSADORA DE COXA E SOBRECOXA - consumo de projeto
		cQuery += " WHERE F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_TIPO=D1_TIPO AND F1_FORNECE=D1_FORNECE AND F1_LOJA=D1_LOJA AND SF1.D_E_L_E_T_='' 

		//cQuery += " WHERE D1_TES=F4_CODIGO 
		cQuery += " AND D1_TES=F4_CODIGO 
		// 
		cQuery += " AND SD1.D1_FILIAL BETWEEN '' AND 'ZZ'

		// @history Ticket 352     - FWNM              - 21/08/2020 - Criar inteligência para não considerar saldo duplicado no momento da classificação
		cQuery += " AND (SD1.D1_FILIAL + SD1.D1_DOC + SD1.D1_SERIE + SD1.D1_TIPO + SD1.D1_FORNECE + SD1.D1_LOJA) NOT IN " + FormatIn(cNFKey,"|")

		// NOTAS CLASSIFICADAS
		// Inibido pois qdo a classificação é estornada, o PC continua com o C7_QUJE preenchido
		//cQuery += " AND SD1.D1_TES <> '' " // Chamado n. 059436 || OS 060933 || CONTROLADORIA || DAIANE || 3549 || PROJETO NEGATIVO - FWNM - 07/07/2020

		cQuery += " AND SD1.D1_PROJETO = '" + cCodPrj + "'
		cQuery += " AND SD1.D1_CF NOT LIKE '3%' " // Desconsidera importacao, Incluido por Adriana - 03/09/2019 - Chamado 051453
		cQuery += " AND SD1.D_E_L_E_T_ = ''
		cQuery += " AND F4_FILIAL='"+FWxFilial("SF4")+"'
		cQuery += " AND F4_DUPLIC = 'S'
		cQuery += " AND SF4.D_E_L_E_T_ = '' 

		tcQuery cQuery new Alias "WorkPRJ"
		
		aTamSX3	:= TamSX3("D1_TOTAL")
		tcSetField("WorkPRJ", "TOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	
		nNFTotPrj := WorkPRJ->TOTAL + nNFITotPrj // Soma Total NF Importacao, Incluido por Adriana - 03/09/2019 - Chamado 051453

		// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 23/10/2019
			If cDespesas == "DESPESAS"

			aTamSX3	:= TamSX3("D1_VALIPI")
			tcSetField("WorkPRJ", "IPI", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("D1_VALFRE")
			tcSetField("WorkPRJ", "FRETE", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("D1_DESPESA")
			tcSetField("WorkPRJ", "DESPESA", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("D1_SEGURO")
			tcSetField("WorkPRJ", "SEGURO", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("D1_ICMSRET")
			tcSetField("WorkPRJ", "ICMSST", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("D1_VALDESC")
			tcSetField("WorkPRJ", "DESCONTO", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			nNFTIPI    := WorkPRJ->IPI
			nNFTFrete  := WorkPRJ->FRETE
			nNFTDespes := WorkPRJ->DESPESA
			nNFTSeguro := WorkPRJ->SEGURO
			nNFTICMSST := WorkPRJ->ICMSST
			nNFTDesc   := WorkPRJ->DESCONTO
		
	    EndIf
	    
		////////////////////////////////////////////////////////////////////////////////////////////////////
		// PC NACIONAL
		////////////////////////////////////////////////////////////////////////////////////////////////////
		// Chamado n. 054064 || OS 055455 || CONTROLADORIA || DAIANE || (16) || SALDO DE PROJETO - FWNM - 11/12/2019
		/*
		If Select("WorkPrj") > 0
			WorkPrj->( dbCloseArea() )
		EndIf
	   
		// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 23/10/2019
		If cDespesas == "DESPESAS"
			cQuery := " SELECT ISNULL(SUM(C7_TOTAL),0) AS TOTAL, "
			cQuery += "        ISNULL(SUM(C7_VALIPI),0) AS IPI, "
			cQuery += "        ISNULL(SUM(C7_VALFRE),0) AS FRETE, "
			cQuery += "        ISNULL(SUM(C7_DESPESA),0) AS DESPESA, "
			cQuery += "        ISNULL(SUM(C7_SEGURO),0) AS SEGURO, "
			cQuery += "        ISNULL(SUM(C7_ICMSRET),0) AS ICMSST, "
			cQuery += "        ISNULL(SUM(C7_VLDESC),0) AS DESCONTO "
		Else
			cQuery := " SELECT ISNULL(SUM(C7_TOTAL+C7_VALFRE+C7_DESPESA+C7_SEGURO+C7_VALIPI+C7_ICMSRET-C7_VLDESC),0) AS TOTAL "
		EndIf
		//
		//cQuery := " SELECT ISNULL(SUM(C7_TOTAL+C7_VALFRE+C7_DESPESA+C7_SEGURO+C7_VALIPI+C7_ICMSRET-C7_VLDESC),0) AS TOTAL "
		cQuery += " FROM " + RetSqlName( "SC7" ) + " SC7 (NOLOCK) "
		cQuery += " WHERE SC7.C7_FILIAL BETWEEN ' ' AND 'ZZ' "
		cQuery += " AND SC7.C7_PROJETO = '" + cCodPrj + "' "
		cQuery += " AND SC7.C7_RESIDUO <> 'S' "
		cQuery += " AND C7_CONAPRO     <> 'R' " // Não trazer os pedidos rejeitados 27/12/2018 William Costa chamado 046075
		cQuery += " AND C7_MOEDA <= 1 "
		cQuery += " AND (SC7.C7_NUM + SC7.C7_ITEM) NOT IN " + FormatIn(cPCItemKey,"|")
		cQuery += " AND SC7.D_E_L_E_T_ = ' ' "
		cQuery += " AND NOT EXISTS "
		cQuery += " ( "
		cQuery += " SELECT 'X' "
		cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "
		cQuery += " WHERE D1_FILIAL=C7_FILIAL "
		cQuery += " AND D1_PEDIDO=C7_NUM "
		cQuery += " AND D1_ITEMPC=C7_ITEM "
		cQuery += " AND D_E_L_E_T_='' "
		cQuery += " ) "
		
		tcQuery cQuery new Alias "WorkPRJ"
		
		aTamSX3	:= TamSX3("C7_TOTAL")
		tcSetField("WorkPRJ", "TOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	
	    nPCTotPrj := WorkPRJ->TOTAL
			
		// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 23/10/2019
		If cDespesas == "DESPESAS"

			aTamSX3	:= TamSX3("C7_VALIPI")
			tcSetField("WorkPRJ", "IPI", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_VALFRE")
			tcSetField("WorkPRJ", "FRETE", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_DESPESA")
			tcSetField("WorkPRJ", "DESPESA", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_SEGURO")
			tcSetField("WorkPRJ", "SEGURO", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_ICMSRET")
			tcSetField("WorkPRJ", "ICMSST", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_VLDESC")
			tcSetField("WorkPRJ", "DESCONTO", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			nPCTIPI    := WorkPRJ->IPI
			nPCTFrete  := WorkPRJ->FRETE
			nPCTDespes := WorkPRJ->DESPESA
			nPCTSeguro := WorkPRJ->SEGURO
			nPCTICMSST := WorkPRJ->ICMSST
			nPCTDesc   := WorkPRJ->DESCONTO
		
	    EndIf
	    
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

		////////////////////////////////////////////////////////////////////////////////////////////////////
		// PC EXTERIOR
		////////////////////////////////////////////////////////////////////////////////////////////////////
		If Select("WorkPrj") > 0
			WorkPrj->( dbCloseArea() )
		EndIf
	   
		// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 23/10/2019
		If cDespesas == "DESPESAS"
			cQuery := " SELECT ISNULL(SUM(C7_TOTAL*C7_XTXMOED),0) AS TOTAL, "
			cQuery += "        ISNULL(SUM(C7_VALIPI*C7_XTXMOED),0) AS IPI, "
			cQuery += "        ISNULL(SUM(C7_VALFRE*C7_XTXMOED),0) AS FRETE, "
			cQuery += "        ISNULL(SUM(C7_DESPESA*C7_XTXMOED),0) AS DESPESA, "
			cQuery += "        ISNULL(SUM(C7_SEGURO*C7_XTXMOED),0) AS SEGURO, "
			cQuery += "        ISNULL(SUM(C7_ICMSRET*C7_XTXMOED),0) AS ICMSST, "
			cQuery += "        ISNULL(SUM(C7_VLDESC*C7_XTXMOED),0) AS DESCONTO "
		Else
			cQuery := " SELECT ISNULL(SUM((C7_TOTAL+C7_VALFRE+C7_DESPESA+C7_SEGURO+C7_VALIPI+C7_ICMSRET-C7_VLDESC)*C7_XTXMOED),0) AS TOTAL "
		EndIf
		//
		//cQuery := " SELECT ISNULL(SUM((C7_TOTAL+C7_VALFRE+C7_DESPESA+C7_SEGURO+C7_VALIPI+C7_ICMSRET-C7_VLDESC)*C7_XTXMOED),0) AS TOTAL "
		cQuery += " FROM " + RetSqlName( "SC7" ) + " SC7 (NOLOCK) "
		cQuery += " WHERE SC7.C7_FILIAL BETWEEN ' ' AND 'ZZ' "
		cQuery += " AND SC7.C7_PROJETO = '" + cCodPrj + "' "
		cQuery += " AND SC7.C7_RESIDUO <> 'S' "
		cQuery += " AND C7_CONAPRO     <> 'R' " // Não trazer os pedidos rejeitados 27/12/2018 William Costa chamado 046075
		cQuery += " AND C7_MOEDA >= 2 "
		cQuery += " AND (SC7.C7_NUM + SC7.C7_ITEM) NOT IN " + FormatIn(cPCItemKey,"|")
		cQuery += " AND SC7.D_E_L_E_T_ = ' ' "
		cQuery += " AND NOT EXISTS "
		cQuery += " ( "
		cQuery += " SELECT 'X' "
		cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "
		cQuery += " WHERE D1_FILIAL=C7_FILIAL "
		cQuery += " AND D1_PEDIDO=C7_NUM "
		cQuery += " AND D1_ITEMPC=C7_ITEM "
		cQuery += " AND D_E_L_E_T_='' "
		cQuery += " ) "
		
		tcQuery cQuery new Alias "WorkPRJ"
		
		aTamSX3	:= TamSX3("C7_TOTAL")
		tcSetField("WorkPRJ", "TOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	
	    nPCTotPrj := nPCTotPrj + WorkPRJ->TOTAL

		// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 23/10/2019
		If cDespesas == "DESPESAS"

			aTamSX3	:= TamSX3("C7_VALIPI")
			tcSetField("WorkPRJ", "IPI", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_VALFRE")
			tcSetField("WorkPRJ", "FRETE", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_DESPESA")
			tcSetField("WorkPRJ", "DESPESA", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_SEGURO")
			tcSetField("WorkPRJ", "SEGURO", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_ICMSRET")
			tcSetField("WorkPRJ", "ICMSST", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_VLDESC")
			tcSetField("WorkPRJ", "DESCONTO", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			nPCTIPI    := nPCTIPI    + WorkPRJ->IPI
			nPCTFrete  := nPCTFrete  + WorkPRJ->FRETE
			nPCTDespes := nPCTDespes + WorkPRJ->DESPESA
			nPCTSeguro := nPCTSeguro + WorkPRJ->SEGURO
			nPCTICMSST := nPCTICMSST + WorkPRJ->ICMSST
			nPCTDesc   := nPCTDesc   + WorkPRJ->DESCONTO
		
	    EndIf
		*/
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

		// PC com PRE-NOTA (MOEDA NACIONAL)
		/*
		If Select("WorkPrj") > 0
			WorkPrj->( dbCloseArea() )
		EndIf
	   
		// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 23/10/2019
		If cDespesas == "DESPESAS"
			cQuery := " SELECT ISNULL(SUM(C7_TOTAL),0) AS TOTAL, "
			cQuery += "        ISNULL(SUM(C7_VALIPI),0) AS IPI, "
			cQuery += "        ISNULL(SUM(C7_VALFRE),0) AS FRETE, "
			cQuery += "        ISNULL(SUM(C7_DESPESA),0) AS DESPESA, "
			cQuery += "        ISNULL(SUM(C7_SEGURO),0) AS SEGURO, "
			cQuery += "        ISNULL(SUM(C7_ICMSRET),0) AS ICMSST, "
			cQuery += "        ISNULL(SUM(C7_VLDESC),0) AS DESCONTO "
		Else
			cQuery := " SELECT ISNULL(SUM(C7_TOTAL+C7_VALFRE+C7_DESPESA+C7_SEGURO+C7_VALIPI+C7_ICMSRET-C7_VLDESC),0) AS TOTAL "
		EndIf
		//
		//cQuery := " SELECT ISNULL(SUM(C7_TOTAL+C7_VALFRE+C7_DESPESA+C7_SEGURO+C7_VALIPI+C7_ICMSRET-C7_VLDESC),0) AS TOTAL "
		cQuery += " FROM " + RetSqlName( "SC7" ) + " SC7 (NOLOCK) "
		cQuery += " WHERE SC7.C7_FILIAL BETWEEN ' ' AND 'ZZ' "
		cQuery += " AND SC7.C7_PROJETO = '" + cCodPrj + "' "
		cQuery += " AND SC7.C7_RESIDUO <> 'S' "
		cQuery += " AND C7_CONAPRO     <> 'R' " // Não trazer os pedidos rejeitados 27/12/2018 William Costa chamado 046075
		cQuery += " AND C7_MOEDA <= 1 "
		cQuery += " AND (SC7.C7_NUM + SC7.C7_ITEM) NOT IN " + FormatIn(cPCItemKey,"|")
		cQuery += " AND SC7.D_E_L_E_T_ = ' ' "
		cQuery += " AND EXISTS "
		cQuery += " ( "
		cQuery += " SELECT 'X' "
		cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "
		cQuery += " WHERE D1_FILIAL=C7_FILIAL "
		cQuery += " AND D1_PEDIDO=C7_NUM "
		cQuery += " AND D1_ITEMPC=C7_ITEM "
		cQuery += " AND D1_TES='' "
		cQuery += " AND D_E_L_E_T_='' "
		cQuery += " ) "
		
		tcQuery cQuery new Alias "WorkPRJ"
		
		aTamSX3	:= TamSX3("C7_TOTAL")
		tcSetField("WorkPRJ", "TOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	
	    nPC2TotPrj := WorkPRJ->TOTAL

		// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 23/10/2019
		If cDespesas == "DESPESAS"

			aTamSX3	:= TamSX3("C7_VALIPI")
			tcSetField("WorkPRJ", "IPI", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_VALFRE")
			tcSetField("WorkPRJ", "FRETE", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_DESPESA")
			tcSetField("WorkPRJ", "DESPESA", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_SEGURO")
			tcSetField("WorkPRJ", "SEGURO", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_ICMSRET")
			tcSetField("WorkPRJ", "ICMSST", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_VLDESC")
			tcSetField("WorkPRJ", "DESCONTO", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			nPC2TIPI    := WorkPRJ->IPI
			nPC2TFrete  := WorkPRJ->FRETE
			nPC2TDespes := WorkPRJ->DESPESA
			nPC2TSeguro := WorkPRJ->SEGURO
			nPC2TICMSST := WorkPRJ->ICMSST
			nPC2TDesc   := WorkPRJ->DESCONTO
		
	    EndIf
	    
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

		// PC com PRE-NOTA (MOEDA ESTRANGEIRA)
		If Select("WorkPrj") > 0
			WorkPrj->( dbCloseArea() )
		EndIf
	   
		// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 23/10/2019
		If cDespesas == "DESPESAS"
			cQuery := " SELECT ISNULL(SUM(C7_TOTAL*C7_XTXMOED),0) AS TOTAL, "
			cQuery += "        ISNULL(SUM(C7_VALIPI*C7_XTXMOED),0) AS IPI, "
			cQuery += "        ISNULL(SUM(C7_VALFRE*C7_XTXMOED),0) AS FRETE, "
			cQuery += "        ISNULL(SUM(C7_DESPESA*C7_XTXMOED),0) AS DESPESA, "
			cQuery += "        ISNULL(SUM(C7_SEGURO*C7_XTXMOED),0) AS SEGURO, "
			cQuery += "        ISNULL(SUM(C7_ICMSRET*C7_XTXMOED),0) AS ICMSST, "
			cQuery += "        ISNULL(SUM(C7_VLDESC*C7_XTXMOED),0) AS DESCONTO "
		Else
			cQuery := " SELECT ISNULL(SUM((C7_TOTAL+C7_VALFRE+C7_DESPESA+C7_SEGURO+C7_VALIPI+C7_ICMSRET-C7_VLDESC)*C7_XTXMOED),0) AS TOTAL "
		EndIf
		//
		//cQuery := " SELECT ISNULL(SUM((C7_TOTAL+C7_VALFRE+C7_DESPESA+C7_SEGURO+C7_VALIPI+C7_ICMSRET-C7_VLDESC)*C7_XTXMOED),0) AS TOTAL "
		cQuery += " FROM " + RetSqlName( "SC7" ) + " SC7 (NOLOCK) "
		cQuery += " WHERE SC7.C7_FILIAL BETWEEN ' ' AND 'ZZ' "
		cQuery += " AND SC7.C7_PROJETO = '" + cCodPrj + "' "
		cQuery += " AND SC7.C7_RESIDUO <> 'S' "
		cQuery += " AND C7_CONAPRO     <> 'R' " // Não trazer os pedidos rejeitados 27/12/2018 William Costa chamado 046075
		cQuery += " AND C7_MOEDA >= 2 "
		cQuery += " AND (SC7.C7_NUM + SC7.C7_ITEM) NOT IN " + FormatIn(cPCItemKey,"|")
		cQuery += " AND SC7.D_E_L_E_T_ = ' ' "
		cQuery += " AND EXISTS "
		cQuery += " ( "
		cQuery += " SELECT 'X' "
		cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "
		cQuery += " WHERE D1_FILIAL=C7_FILIAL "
		cQuery += " AND D1_PEDIDO=C7_NUM "
		cQuery += " AND D1_ITEMPC=C7_ITEM "
		cQuery += " AND D1_TES='' "
		cQuery += " AND D_E_L_E_T_='' "
		cQuery += " ) "
		
		tcQuery cQuery new Alias "WorkPRJ"
		
		aTamSX3	:= TamSX3("C7_TOTAL")
		tcSetField("WorkPRJ", "TOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	
	    nPC2TotPrj := nPC2TotPrj + WorkPRJ->TOTAL

		// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 23/10/2019
		If cDespesas == "DESPESAS"

			aTamSX3	:= TamSX3("C7_VALIPI")
			tcSetField("WorkPRJ", "IPI", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_VALFRE")
			tcSetField("WorkPRJ", "FRETE", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_DESPESA")
			tcSetField("WorkPRJ", "DESPESA", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_SEGURO")
			tcSetField("WorkPRJ", "SEGURO", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_ICMSRET")
			tcSetField("WorkPRJ", "ICMSST", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			aTamSX3	:= TamSX3("C7_VLDESC")
			tcSetField("WorkPRJ", "DESCONTO", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			
			nPC2TIPI    := nPC2TIPI    + WorkPRJ->IPI
			nPC2TFrete  := nPC2TFrete  + WorkPRJ->FRETE
			nPC2TDespes := nPC2TDespes + WorkPRJ->DESPESA
			nPC2TSeguro := nPC2TSeguro + WorkPRJ->SEGURO
			nPC2TICMSST := nPC2TICMSST + WorkPRJ->ICMSST
			nPC2TDesc   := nPC2TDesc   + WorkPRJ->DESCONTO
		
	    EndIf
		*/
		
		// Chamado 050791 - pedido com saldo parcial do item. Exemplo: C7_QUJE < C7_QUANT e C7_QUJE > 0 e C7_ENCER<>E - FWNM - 30/07/2019                  
	   	/*
	   	Regra criada e conferida com o PC n. 352388, filial 02 (entregas parciais de um unico item), empresa Adoro
	   	Projeto n. 021803001
	   	*/                                                                   
	   	
		// (MOEDA NACIONAL)
		If Select("WorkPrj") > 0
			WorkPrj->( dbCloseArea() )
		EndIf
	    
		cQuery := " SELECT ISNULL(ROUND(SUM((C7_QUANT-C7_QUJE)*C7_PRECO),2),0)                                              AS TOTAL, 
		cQuery += "	ISNULL(ROUND(SUM((C7_VALIPI/CASE WHEN C7_QUANT = 0 THEN 1 ELSE C7_QUANT END)*(C7_QUANT-C7_QUJE)),2),0)  AS IPI, 
		cQuery += " ISNULL(ROUND(SUM((C7_VALFRE/CASE WHEN C7_QUANT = 0 THEN 1 ELSE C7_QUANT END)*(C7_QUANT-C7_QUJE)),2),0)  AS FRETE, 
		cQuery += " ISNULL(ROUND(SUM((C7_DESPESA/CASE WHEN C7_QUANT = 0 THEN 1 ELSE C7_QUANT END)*(C7_QUANT-C7_QUJE)),2),0) AS DESPESA, 
		cQuery += " ISNULL(ROUND(SUM((C7_SEGURO/CASE WHEN C7_QUANT = 0 THEN 1 ELSE C7_QUANT END)*(C7_QUANT-C7_QUJE)),2),0)  AS SEGURO,  
		cQuery += " ISNULL(ROUND(SUM((C7_ICMSRET/CASE WHEN C7_QUANT = 0 THEN 1 ELSE C7_QUANT END)*(C7_QUANT-C7_QUJE)),2),0) AS ICMSST,
		cQuery += " ISNULL(ROUND(SUM(C7_VLDESC),2),0)                                                                       AS DESCONTO 
		cQuery += " FROM " + RetSqlName( "SC7" ) + " SC7 (NOLOCK) "
		cQuery += " WHERE SC7.C7_FILIAL BETWEEN ' ' AND 'ZZ' "
		cQuery += " AND SC7.C7_PROJETO = '" + cCodPrj + "' "
		cQuery += " AND SC7.C7_RESIDUO <> 'S' "
		cQuery += " AND C7_CONAPRO     <> 'R' " // Não trazer os pedidos rejeitados 27/12/2018 William Costa chamado 046075
		cQuery += " AND C7_MOEDA <= 1 "
		cQuery += " AND (SC7.C7_NUM + SC7.C7_ITEM) NOT IN " + FormatIn(cPCItemKey,"|")
		//cQuery += " AND C7_ENCER<>'E' "
		//cQuery += " AND C7_QUJE>0 "
		//cQuery += " AND C7_QUANT<>C7_QUJE "
		cQuery += " AND SC7.D_E_L_E_T_ = ' ' "
		/*
		cQuery += " AND EXISTS "
		cQuery += " ( "
		cQuery += " SELECT 'X' "
		cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "
		cQuery += " WHERE D1_FILIAL=C7_FILIAL "
		cQuery += " AND D1_PEDIDO=C7_NUM "
		cQuery += " AND D1_ITEMPC=C7_ITEM "
		cQuery += " AND D_E_L_E_T_='' "
		cQuery += " ) "
		*/

		// DEBUG
		//cQuery += " AND C7_NUM='388953'
		//

		tcQuery cQuery new Alias "WorkPRJ"
		
		aTamSX3	:= TamSX3("C7_TOTAL")
		tcSetField("WorkPRJ", "TOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2])

		aTamSX3	:= TamSX3("C7_VALIPI")
		tcSetField("WorkPRJ", "IPI", aTamSX3[3], aTamSX3[1], aTamSX3[2])

		aTamSX3	:= TamSX3("C7_VALFRE")
		tcSetField("WorkPRJ", "FRETE", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	                                
		aTamSX3	:= TamSX3("C7_DESPESA")
		tcSetField("WorkPRJ", "DESPESA", aTamSX3[3], aTamSX3[1], aTamSX3[2])
                                      
		aTamSX3	:= TamSX3("C7_SEGURO")
		tcSetField("WorkPRJ", "SEGURO", aTamSX3[3], aTamSX3[1], aTamSX3[2])
                                     
		aTamSX3	:= TamSX3("C7_ICMSRET")
		tcSetField("WorkPRJ", "ICMSST", aTamSX3[3], aTamSX3[1], aTamSX3[2])

		// @history Ticket 313     - FWNM              - 21/08/2020 - Considerar desconto do pedido de compra, campo C7_VLDESC
		aTamSX3	:= TamSX3("C7_VLDESC")
		tcSetField("WorkPRJ", "DESCONTO", aTamSX3[3], aTamSX3[1], aTamSX3[2])
		//

		If cDespesas == "DESPESAS"
			nPC3TotPrj := WorkPRJ->TOTAL
		Else
			nPC3TotPrj := WorkPRJ->TOTAL + WorkPRJ->IPI + WorkPRJ->FRETE + WorkPRJ->DESPESA + WorkPRJ->SEGURO + WorkPRJ->ICMSST
	    EndIf 

		// @history Ticket 313     - FWNM              - 21/08/2020 - Considerar desconto do pedido de compra, campo C7_VLDESC
		nPCDescont := WorkPRJ->DESCONTO
		nPC3TotPrj := nPC3TotPrj - nPCDescont
		//

		If cDespesas == "DESPESAS"
			nPC3TIPI    := WorkPRJ->IPI
			nPC3TFrete  := WorkPRJ->FRETE
			nPC3TDespes := WorkPRJ->DESPESA
			nPC3TSeguro := WorkPRJ->SEGURO
			nPC3TICMSST := WorkPRJ->ICMSST
	    EndIf
	    
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
		// PC ESTRANGEIRO
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

		// Chamado 050791 - pedido com saldo parcial do item. Exemplo: C7_QUJE < C7_QUANT e C7_QUJE > 0 e C7_ENCER<>E - FWNM - 30/07/2019                  
	   	/*
	   	Regra criada e conferida com o PC n. 352388, filial 02 (entregas parciais de um unico item), empresa Adoro
	   	Projeto n. 021803001
	   	*/                                                                   
	   	
		// (MOEDA ESTRANGEIRA)
		If Select("WorkPrj") > 0
			WorkPrj->( dbCloseArea() )
		EndIf
	    
		cQuery := " SELECT ISNULL(ROUND(SUM(((C7_QUANT-C7_QUJE)*C7_PRECO)*C7_XTXMOED),2),0)       AS TOTAL, 
		cQuery += "	ISNULL(ROUND(SUM(((C7_VALIPI/C7_QUANT)*(C7_QUANT-C7_QUJE))*C7_XTXMOED),2),0)  AS IPI, 
		cQuery += " ISNULL(ROUND(SUM(((C7_VALFRE/C7_QUANT)*(C7_QUANT-C7_QUJE))*C7_XTXMOED),2),0)  AS FRETE, 
		cQuery += " ISNULL(ROUND(SUM(((C7_DESPESA/C7_QUANT)*(C7_QUANT-C7_QUJE))*C7_XTXMOED),2),0) AS DESPESA, 
		cQuery += " ISNULL(ROUND(SUM(((C7_SEGURO/C7_QUANT)*(C7_QUANT-C7_QUJE))*C7_XTXMOED),2),0)  AS SEGURO,  
		cQuery += " ISNULL(ROUND(SUM(((C7_ICMSRET/C7_QUANT)*(C7_QUANT-C7_QUJE))*C7_XTXMOED),2),0) AS ICMSST,
		cQuery += " ISNULL(ROUND(SUM(C7_VLDESC),2),0)                                             AS DESCONTO 
		cQuery += " FROM " + RetSqlName( "SC7" ) + " SC7 (NOLOCK) "
		cQuery += " WHERE SC7.C7_FILIAL BETWEEN ' ' AND 'ZZ' "
		cQuery += " AND SC7.C7_PROJETO = '" + cCodPrj + "' "
		cQuery += " AND SC7.C7_RESIDUO <> 'S' "
		cQuery += " AND C7_CONAPRO     <> 'R' " // Não trazer os pedidos rejeitados 27/12/2018 William Costa chamado 046075
		cQuery += " AND C7_MOEDA >= 2 "
		cQuery += " AND (SC7.C7_NUM + SC7.C7_ITEM) NOT IN " + FormatIn(cPCItemKey,"|")
		//cQuery += " AND C7_ENCER<>'E' "
		//cQuery += " AND C7_QUJE>0 "
		//cQuery += " AND C7_QUANT<>C7_QUJE "
		cQuery += " AND SC7.D_E_L_E_T_ = ' ' "
		/*
		cQuery += " AND EXISTS "
		cQuery += " ( "
		cQuery += " SELECT 'X' "
		cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "
		cQuery += " WHERE D1_FILIAL=C7_FILIAL "
		cQuery += " AND D1_PEDIDO=C7_NUM "
		cQuery += " AND D1_ITEMPC=C7_ITEM "
		cQuery += " AND D_E_L_E_T_='' "
		cQuery += " ) "
		*/
		tcQuery cQuery new Alias "WorkPRJ"
		
		aTamSX3	:= TamSX3("C7_TOTAL")
		tcSetField("WorkPRJ", "TOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2])

		aTamSX3	:= TamSX3("C7_VALIPI")
		tcSetField("WorkPRJ", "IPI", aTamSX3[3], aTamSX3[1], aTamSX3[2])

		aTamSX3	:= TamSX3("C7_VALFRE")
		tcSetField("WorkPRJ", "FRETE", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	                                
		aTamSX3	:= TamSX3("C7_DESPESA")
		tcSetField("WorkPRJ", "DESPESA", aTamSX3[3], aTamSX3[1], aTamSX3[2])
                                      
		aTamSX3	:= TamSX3("C7_SEGURO")
		tcSetField("WorkPRJ", "SEGURO", aTamSX3[3], aTamSX3[1], aTamSX3[2])
                                     
		aTamSX3	:= TamSX3("C7_ICMSRET")
		tcSetField("WorkPRJ", "ICMSST", aTamSX3[3], aTamSX3[1], aTamSX3[2])

		// @history Ticket 313     - FWNM              - 21/08/2020 - Considerar desconto do pedido de compra, campo C7_VLDESC
		aTamSX3	:= TamSX3("C7_VLDESC")
		tcSetField("WorkPRJ", "DESCONTO", aTamSX3[3], aTamSX3[1], aTamSX3[2])
		//

		If cDespesas == "DESPESAS"
			nPC3TotPrj := nPC3TotPrj + WorkPRJ->TOTAL
		Else
			nPC3TotPrj := nPC3TotPrj + WorkPRJ->TOTAL + WorkPRJ->IPI + WorkPRJ->FRETE + WorkPRJ->DESPESA + WorkPRJ->SEGURO + WorkPRJ->ICMSST
		EndIf

		// @history Ticket 313     - FWNM              - 21/08/2020 - Considerar desconto do pedido de compra, campo C7_VLDESC
		nPCDescont := WorkPRJ->DESCONTO
		nPC3TotPrj := nPC3TotPrj - nPCDescont
		//

		If cDespesas == "DESPESAS"
			nPC3TIPI    := nPC3TIPI    + WorkPRJ->IPI
			nPC3TFrete  := nPC3TFrete  + WorkPRJ->FRETE
			nPC3TDespes := nPC3TDespes + WorkPRJ->DESPESA
			nPC3TSeguro := nPC3TSeguro + WorkPRJ->SEGURO
			nPC3TICMSST := nPC3TICMSST + WorkPRJ->ICMSST
	    EndIf
	    
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

		// Totaliza NF Devolucoes Compras (SD2)
		If Select("WorkPrj") > 0
			WorkPrj->( dbCloseArea() )
		EndIf
	
		cQuery := " SELECT ISNULL(SUM(SD2.D2_TOTAL-SD2.D2_DESCON),0) AS TOTAL "
		cQuery += " FROM " + RetSqlName( "SD2" ) + " SD2 (NOLOCK) "
		cQuery += " WHERE SD2.D2_XPROJET = '" + cCodPrj + "' "
		cQuery += " AND SD2.D2_TIPO = 'D' "
		cQuery += " AND SD2.D_E_L_E_T_ = ' ' "
		
		tcQuery cQuery new Alias "WorkPRJ"
		
		aTamSX3	:= TamSX3("D2_TOTAL")
		tcSetField("WorkPRJ", "TOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	
	    nDevTotPrj := WorkPRJ->TOTAL
	
		// Totaliza SA (SCP)
		If Select("WorkPrj") > 0
			WorkPrj->( dbCloseArea() )
		EndIf
	
		cQuery := " SELECT ISNULL(SUM(SCP.CP_XPRJVLR),0) AS TOTAL "
		cQuery += " FROM " + RetSqlName( "SCP" ) + " SCP (NOLOCK) "
		cQuery += " WHERE SCP.CP_CONPRJ = '" + cCodPrj + "' "
		cQuery += " AND SCP.D_E_L_E_T_ = ' ' "
		
		tcQuery cQuery new Alias "WorkPRJ"
		
		aTamSX3	:= TamSX3("CP_XPRJVLR")
		tcSetField("WorkPRJ", "TOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	
	    nSATotPrj := WorkPRJ->TOTAL
	                               
		// Totalizadores Projeto
	    //nToTPrj := nNFTotPrj + nPCTotPrj + nPC2TotPrj + nSATotPrj - nDevTotPrj
	    nToTPrj := nNFTotPrj + nPCTotPrj + nPC2TotPrj + nPC3TotPrj + nSATotPrj - nDevTotPrj
		
		If AllTrim(cOrigem) <> "BROWSE"
			nSldPrj := nVlrPrj - nTotPrj  // Saldo PRJ
		Else
			nSldPrj := nTotPrj // Consumo PRJ
		EndIf
		
		WorkPrj->( dbCloseArea() )
		
	EndIf
	
	RestArea( aAreaATU )

	// Chamado n. 052816 || OS 054164 || CONTROLADORIA || LUIZ || 8451 || CONTROLE DE PROJETOS - FWNM - 23/10/2019
	If cDespesas == "DESPESAS"

		aDespesas := {; 
					  nNFTotPrj + nPCTotPrj + nPC2TotPrj + nPC3TotPrj ,;
		              nNFIIPI + nNFTIPI + nPCTIPI + nPC2TIPI + nPC3TIPI ,;
		              nNFIFrete + nNFTFrete + nPCTFrete + nPC2TFrete + nPC3TFrete ,;
		              nNFIDespes + nNFTDespes + nPCTDespes + nPC2TDespes + nPC3TDespes ,;      
		              nNFISeguro + nNFTSeguro + nPCTSeguro + nPC2TSeguro + nPC3TSeguro ,;
		              nNFIICMSST + nNFTICMSST + nPCTICMSST + nPC2TICMSST + nPC3TICMSST ,;   
		              nNFIDesc + nNFTDesc + nPCTDesc + nPC2TDesc + nPC3TDesc ,;
		              nDevTotPrj ,;
		              nNFIICMS ,;
		              nNFIPIS  ,;    
		              nNFICOF ,;
		              nSATotPrj ;
		              }
		              
		Return aDespesas
	
	EndIf
	//
		
Return nSldPrj
