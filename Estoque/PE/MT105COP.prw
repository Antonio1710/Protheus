#include "protheus.ch"

/*/{Protheus.doc} User Function MT105COP
    Ponto de entrada para nao copiar campos especificos do usuario quando for utilizada a opcao copia da SA.
    @type  Function
    @author Fernando Macieira
    @since 14/12/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 6467 - Erro Rotina Solicitação ao Armazem - MATA105
    /*/
User Function MT105COP()

    Local cMT105Cop := "CP_EMISSAO"
    
Return cMT105Cop
