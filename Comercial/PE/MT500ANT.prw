#include "protheus.ch"

/*/{Protheus.doc} User Function MT500ANT
    PE executado antes da eliminação de resíduo por registro do SC6
    @type  Function
    @author FWNM
    @since 24/03/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 056247 - FWNM     - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
/*/
User Function MT500ANT()

    Local lRet := .T.

    FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
    If FIE->( dbSeek(FWxFilial("FIE")+"R"+SC5->C5_NUM) )
        lRet := .f.
    EndIf
    
Return lRet