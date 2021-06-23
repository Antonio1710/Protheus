#INCLUDE "rwmake.ch"

/*/{Protheus.doc} User Function nomeFunction
    Filtra titulos que farao parte do bordero
    @type  Function
    @author HCConsys
    @since AGO/2008
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history chamado 056247 - FWNM      - 23/03/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
/*/
User Function FA060QRY()

    Local cFiltro := ""
    
    cFiltro += " E1_BANCO = '" + cPort060 + "' "
    cFiltro += " AND E1_XWSBRAC='' " // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 23/03/2020

Return cFiltro
