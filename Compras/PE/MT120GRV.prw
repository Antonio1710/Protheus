#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function MT120GRV
    Localização.: Function A120Pedido - Rotina de Inclusão, Alteração, Exclusão e Consulta dos Pedidos de Compras e Autorizações de Entrega.Finalidade...: O  ponto de entrada MT120GRV utilizado para continuar ou não a Inclusão, alteração ou exclusão do Pedido de Compra ou Autorização de Entrega.
    Sintaxe MT120GRV - Continuar ou não a inclusão, alteração ou exclusão ( [ ParamIxb[1] ], [ ParamIxb[2] ], [ ParamIxb[3] ], [ ParamIxb[4] ] ) -->
    @type  Function
    @author Fernando Macieira
    @since 25/05/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 14352   - Fernando Macieira - 24/05/2021 - Saldo Negativo
/*/
User Function MT120GRV()
    
    Local cNum    := PARAMIXB[1]
    Local lInclui := PARAMIXB[2]
    Local lAltera := PARAMIXB[3]
    Local lExclui := PARAMIXB[4]
    Local lRet    := .T.
    
    If lAltera .or. lExclui

        SD1->( dbSetOrder(22) ) // D1_FILIAL, D1_PEDIDO, D1_ITEMPC, R_E_C_N_O_, D_E_L_E_T_
        If SD1->( dbSeek(FWxFilial("SD1")+cNum) )
            lRet := .f.
            MessageBox("Alteração não permitida!" + Chr(13)+Chr(10) + "PC está amarrado a NF n. " + SD1->D1_DOC + "/" + SD1->D1_SERIE,"MT120GRV-01 (PC com movimentações)",48)
        EndIf

    EndIf    
    
Return lRet
