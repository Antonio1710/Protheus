#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function MTA456P
    Ponto de entrada disparado na rotina FATURAMENTO > ATUALIZAÇÕES > PEDIDOS > LIEBRAÇAO CRED/EST > MANUAL, no momento em que se clica em qualquer um dos botões que segue de um pedido que ainda não foi liberado:  Lib. Todos  / Rejeita / OK / Cancelar.
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
    @history ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identificação para liberação manual
    @history ticket 71027 - Fernando Macieira - 07/04/2022 - Liberação Pedido Antecipado sem Aprovação Financeiro - PV 9BEGCC foi incluído depois que o job do boleto parou, não gerou FIE e SE1 (PR) e foi liberado manualmente pelo financeiro, sendo faturado como pv normal... por isso da dupla checagem
/*/
User Function MTA456P()

    Local lRet := .t.

    FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
    If FIE->( dbSeek(SC5->C5_FILIAL+"R"+SC5->C5_NUM) )
		//If AllTrim(SC5->C5_XWSPAGO) <> "S"
		If Empty(AllTrim(SC5->C5_XWSPAGO)) // ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identificação para liberação manual
			lRet := .f.
			msgAlert("Pedido de Adiantamento " + SC5->C5_NUM + " não foi pago! Liberação não permitida...","[MTA456P-01] - Bradesco WS")
		EndIf
	EndIf

    // @history ticket 71027 - Fernando Macieira - 07/04/2022 - Liberação Pedido Antecipado sem Aprovação Financeiro - PV 9BEGCC foi incluído depois que o job do boleto parou, não gerou FIE e SE1 (PR) e foi liberado manualmente pelo financeiro, sendo faturado como pv normal... por isso da dupla checagem
    If lRet
        If Posicione("SE4",1,FWxFilial("SE4")+SC5->C5_CONDPAG,"E4_CTRADT") == '1' // Condição Pagto Adiantamento
            If Empty(SC5->C5_XWSPAGO)
                lRet := .f.
                msgAlert("Pedido de Adiantamento " + SC5->C5_NUM + " não foi pago! Liberação não permitida...","[MTA456P-02] - Bradesco WS")
            EndIf
        EndIf
    EndIf
    //

Return lRet
