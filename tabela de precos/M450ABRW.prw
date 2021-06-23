#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function M450ABRW
    Ponto Entrada análise cliente - opção Automática
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
/*/
User Function M450ABRW()

    Local cQuery := ParamIXB[1]

    If Select("WorkWSPago") > 0
        WorkWSPago->( dbCloseArea() )
    EndIf

    tcQuery cQuery New Alias "WorkWSPago"

    cQuery += " AND SC5.R_E_C_N_O_ NOT IN ( "

    WorkWSPago->( dbGoTop() )
    Do While WorkWSPago->( !EOF() )

        FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
        If FIE->( dbSeek(WorkWSPago->C5_FILIAL+"R"+WorkWSPago->C9_PEDIDO) )
			//If AllTrim(Posicione("SC5",1,WorkWSPago->(C5_FILIAL+C9_PEDIDO),"C5_XWSPAGO")) <> "S"
			If Empty(AllTrim(Posicione("SC5",1,WorkWSPago->(C5_FILIAL+C9_PEDIDO),"C5_XWSPAGO"))) // ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identificação para liberação manual
                cQuery += AllTrim(Str(SC5->(Recno()))) + ","
            EndIf
		EndIf

        WorkWSPago->( dbSkip() )
    EndDo

    cQuery += " '' ) "

    If Select("WorkWSPago") > 0
        WorkWSPago->( dbCloseArea() )
    EndIf

Return cQuery
