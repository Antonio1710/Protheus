#include "rwmake.ch"
#include "Protheus.ch"

/*/{Protheus.doc} User Function MT440LIB
	O ponto de entrada "MT440LIB" é executado somente pela opção: Automático da rotina de Liberação de Pedidos de Venda.
	@type  Function
	@author FWNM
	@since 09/04/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 056247 - FWNM   - 09/04/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history ticket 102 - FWNM - 18/08/2020 - WS BRADESCO - Gerar boleto mesmo com bloqueio comercial
/*/
User Function MT440LIB()

	Local nQtdLib := PARAMIXB

    //@history ticket 102 - FWNM - 18/08/2020 - WS BRADESCO - Gerar boleto mesmo com bloqueio comercial
    /*
	FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
	If FIE->( dbSeek(SC6->C6_FILIAL+"R"+SC6->C6_NUM) )
			
		If AllTrim(Posicione("SC5",1,SC6->(C6_FILIAL+C6_NUM),"C5_XWSPAGO")) == "S"
			nQtdLib := 0

			// Bloqueia por regra
			RecLock("SC5", .f.)
                SC5->C5_LIBEROK := ""
                SC5->C5_BLQ     := "1" // Pedido Bloquedo por regra
            SC5->( msUnLock() )
		EndIf

		// Bloqueia Crédito independentemente dos campos padroes como A1_RISCO e/ou A1_LC
		cSql := " UPDATE " + RetSqlName("SC9") + " SET C9_BLCRED='01'
		cSql += " WHERE C9_FILIAL='"+SC6->C6_FILIAL+"'
		cSql += " AND C9_PEDIDO='"+SC6->C6_NUM+"'
		cSql += " AND D_E_L_E_T_='' 

		tcSQLExec(cSql)

	EndIf
	*/
	
Return nQtdLib
