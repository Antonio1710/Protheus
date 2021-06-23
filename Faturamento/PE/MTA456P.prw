#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function MTA456P
    Ponto de entrada disparado na rotina FATURAMENTO > ATUALIZA��ES > PEDIDOS > LIEBRA�AO CRED/EST > MANUAL, no momento em que se clica em qualquer um dos bot�es que segue de um pedido que ainda n�o foi liberado:  Lib. Todos  / Rejeita / OK / Cancelar.
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
    @history ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identifica��o para libera��o manual
/*/
User Function MTA456P()

    Local lRet := .t.

    FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
    If FIE->( dbSeek(SC5->C5_FILIAL+"R"+SC5->C5_NUM) )
		//If AllTrim(SC5->C5_XWSPAGO) <> "S"
		If Empty(AllTrim(SC5->C5_XWSPAGO)) // ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identifica��o para libera��o manual
			lRet := .f.
			msgAlert("Pedido de Adiantamento " + SC5->C5_NUM + " n�o foi pago! Libera��o n�o permitida...","[MTA456P-01] - Bradesco WS")
		EndIf
	EndIf

Return lRet
