#include "protheus.ch"

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
    @history Chamado TI - Leonardo P. Monteiro    - 29/11/2021 - Nova compila��o em produ��o.
/*/
User Function MTA265MNU()

    aAdd(aRotina,{ "* Endere�a A2_XTIPO=4", "u_RunChkSDA()", 0 , 2, 0, .F.})	
    
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
    
    FWMsgRun(, {|| u_ChkSDA() }, "Aguarde", "Checando endere�amentos pendentes ["+Time()+"] ...")

    msgInfo("Endere�amentos pendentes finalizados! Verifique... ")

Return
