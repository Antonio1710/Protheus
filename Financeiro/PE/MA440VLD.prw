#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function MA440VLD
    O ponto de entrada Ma440VLD será executado na confirmação da liberação de um pedido de vendas e será utilizado para que o usuário possa realizar validações antes de efetuar a autorização de liberação.
    @type  Function
    @author FWNM
    @since 09/04/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
    @history chamado NNNNNN - ANALISTA - DATA - DESCRIÇÃO
    @history ticket 102 - FWNM - 18/08/2020 - WS BRADESCO - Gerar boleto mesmo com bloqueio comercial
/*/
User Function MA440VLD()

    Local lRet := .t.

    //@history ticket 102 - FWNM - 18/08/2020 - WS BRADESCO - Gerar boleto mesmo com bloqueio comercial
    /*
    FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
    If FIE->( dbSeek(SC5->C5_FILIAL+"R"+SC5->C5_NUM) )
	
        If AllTrim(SC5->C5_XWSPAGO) <> "S"
		
        	lRet := .f.

            RecLock("SC5", .f.)
                SC5->C5_LIBEROK := ""
                SC5->C5_BLQ     := "1" //Pedido Bloquedo por regra
            SC5->( msUnLock() )
            
            // Bloqueia Crédito independentemente dos campos padroes como A1_RISCO e/ou A1_LC
			cSql := " UPDATE " + RetSqlName("SC9") + " SET C9_BLCRED='01'
			cSql += " WHERE C9_FILIAL='"+FWxFilial("SC9")+"'
			cSql += " AND C9_PEDIDO='"+SC5->C5_NUM+"'
			cSql += " AND D_E_L_E_T_='' 

			tcSQLExec(cSql)

			msgAlert("Pedido de Adiantamento não foi pago! Liberação não permitida...","[MA440VLD-01] - Bradesco WS")
		
        EndIf		
    
    EndIf
    */

Return lRet
