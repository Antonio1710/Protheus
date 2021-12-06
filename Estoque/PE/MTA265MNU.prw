#include "protheus.ch"

/*/{Protheus.doc} User Function nomeFunction
    (long_description)
    @type  Function
    @author Fernando Macieira
    @since 01/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history Ticket 62276   - Fer Macieira    - 06/12/2021 - Endereçamento automático - Armazéns de terceiros 70 a 74 - Projeto Industrialização - Alguns casos o EXECAUTO retorna ERRO
/*/
User Function MTA265MNU()

    aAdd(aRotina,{ "* Endereça A2_XTIPO=4", "u_RunChkSDA()", 0 , 2, 0, .F.})	
    
Return

/*/{Protheus.doc} User Function nomeFunction
    (long_description)
    @type  Function
    @author user
    @since 01/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function RunChkSDA()
    
    FWMsgRun(, {|| u_ChkSDA() }, "Aguarde", "Checando endereçamentos pendentes ["+Time()+"] ...")

    msgInfo("Endereçamentos pendentes finalizados! Verifique... ")

Return
