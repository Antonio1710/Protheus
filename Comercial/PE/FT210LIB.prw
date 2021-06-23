#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function FT210LIB
    Ponto Entrada executado após a liberação do pedido de venda bloqueado por regra de negócio. Somente o pedido de venda esta posicionado no momento da execução do ponto de entrada e na mesma transação da operação do sistema.
    @type  Function
    @author FWNM
    @since 22/04/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
    @history ticket 102 - FWNM - 18/08/2020 - WS BRADESCO - Gerar boleto mesmo com bloqueio comercial
/*/
User Function FT210LIB()

    //@history ticket 102 - FWNM - 18/08/2020 - WS BRADESCO - Gerar boleto mesmo com bloqueio comercial
    /*
    Local lCondRA   := AllTrim(Posicione("SE4",1,FWxFilial("SE4")+SC5->C5_CONDPAG,"E4_CTRADT")) == "1" // Cond Adiantamento = SIM
    Local lBlqRegra := Empty(SC5->C5_BLQ)
    
    If lCondRA .and. lBlqRegra

        // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 22/04/2020
        msAguarde( { || u_GeraRAPV() }, "Gerando boleto de adiantamento e amarração com PV n " + SC5->C5_NUM )
        
        // Checo amarração RA x PV
        FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
        If FIE->( dbSeek(SC5->C5_FILIAL+"R"+SC5->C5_NUM) )
            U_ADVEN050P(SC5->C5_NUM,.T.,.F.,"",.F.,.F.,.F.,.F.,.F.,.F.,0,1)
        EndIf
        //

    EndIf
    */

Return
