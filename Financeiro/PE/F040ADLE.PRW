#include "protheus.ch"

/*/{Protheus.doc} User Function F040ADLE
    Central Aprovação - Legenda
    @type  Function
    @author Ricardo Lima
    @since 14/11/2017
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 038609
    @history chamado 058216 - FWNM     - 15/05/2020 - OS 059676 || FINANCAS || LUIZ || 8451 || CONTAS APAGAR
/*/
User Function F040ADLE

    Local aRet := {}              

    //aAdd(aRet,{"BR_MARROM","Título Com Divergencia"})
    aAdd(aRet,{"BR_MARROM","Central Aprovação - Em análise e/ou Reprovado"}) // Chamado n. 058216 || OS 059676 || FINANCAS || LUIZ || 8451 || CONTAS APAGAR - FWNM - 15/05/2020

Return aRet