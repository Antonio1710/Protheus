#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function FT210OPC
    Ponto Entrada liberação de regra
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
    @history chamado CHAMADO - ANALISTA - DATA - DESCRIÇÃO
/*/
User Function FT210OPC()

    Local nOpcA := ParamIXB[1]

	/*
    FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
    If FIE->( dbSeek(SC5->C5_FILIAL+"R"+SC5->C5_NUM) )
        If AllTrim(SC5->C5_XWSPAGO) <> "S"
            nOpcA := 0
            msgAlert("Pedido de Adiantamento não foi pago! Liberação não permitida...","[FT210OPC-01] - Bradesco WS")
        EndIf
    EndIf
    */
    
Return nOpcA