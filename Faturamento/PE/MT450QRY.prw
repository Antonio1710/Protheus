#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function MT450QRY
    Ponto Entrada análise crédito PV - opção Automática
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
User Function MT450QRY()

    Local cQuery := ParamIXB[1]

    If Select("WorkWSPago") > 0
        WorkWSPago->( dbCloseArea() )
    EndIf

    tcQuery cQuery New Alias "WorkWSPago"

    cQuery += " AND SC9.R_E_C_N_O_ NOT IN ( "

    WorkWSPago->( dbGoTop() )
    Do While WorkWSPago->( !EOF() )

        FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
        If FIE->( dbSeek(WorkWSPago->C9_FILIAL+"R"+WorkWSPago->C9_PEDIDO) )
			//If AllTrim(Posicione("SC5",1,WorkWSPago->(C9_FILIAL+C9_PEDIDO),"C5_XWSPAGO")) <> "S"
			If Empty(AllTrim(Posicione("SC5",1,WorkWSPago->(C9_FILIAL+C9_PEDIDO),"C5_XWSPAGO"))) // ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identificação para liberação manual
                cQuery += AllTrim(Str(WorkWSPago->RECNO)) + ","
            EndIf
		EndIf

        // @history ticket 71027 - Fernando Macieira - 07/04/2022 - Liberação Pedido Antecipado sem Aprovação Financeiro - PV 9BEGCC foi incluído depois que o job do boleto parou, não gerou FIE e SE1 (PR) e foi liberado manualmente pelo financeiro, sendo faturado como pv normal... por isso da dupla checagem
        SC5->( dbSetOrder(1) ) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
        If SC5->( dbSeek(WorkWSPago->(C5_FILIAL+C9_PEDIDO)) )
            If Posicione("SE4",1,FWxFilial("SE4")+SC5->C5_CONDPAG,"E4_CTRADT") == '1' // Condição Pagto Adiantamento
                If Empty(SC5->C5_XWSPAGO)
                    cQuery += AllTrim(Str(WorkWSPago->RECNO)) + ","
                EndIf
            EndIf
        EndIf
        //

        WorkWSPago->( dbSkip() )

    EndDo

    cQuery += " '' ) "

    If Select("WorkWSPago") > 0
        WorkWSPago->( dbCloseArea() )
    EndIf

Return cQuery
