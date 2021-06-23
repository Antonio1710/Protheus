#include "protheus.ch"

/*/{Protheus.doc} User Function F090FILB
    Complemento do Filtro padrão da rotina Baixa Pagar Automática Multifilial (FINA091)
    Programa Fonte
    @type  Function
    @author FWNM
    @since 18/05/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado n. 058216 || OS 059676 || FINANCAS || LUIZ || 8451 || CONTAS APAGAR
    @history chamado NNNNNN - ANALISTA - DATA - DETALHAMENTO
/*/
User Function F090FILB()

    Local cFilter := ParamIXB[1] //Filtro padrão

    cFilter += " AND E2_RJ<>'X' AND E2_XDIVERG<>'S' "
    
Return cFilter