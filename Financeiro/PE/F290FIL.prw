#include "protheus.ch"

/*/{Protheus.doc} User Function F290FIL
    O ponto de entrada F290FIL é executado após confirmar a tela de faturas a pagar e  utilizado na montagem do filtro da Indregua. 
    Caso o ponto de entrada exista, o filtro retornado é anexado ao filtro padrão.
    Programa Fonte
    @type  Function
    @author FWNM
    @since 15/05/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado n. 058216 || OS 059676 || FINANCAS || LUIZ || 8451 || CONTAS APAGAR
    @history chamado NNNNNN - ANALISTA - DATA - DETALHAMENTO
/*/
User Function F290FIL()

    Local cFil290 := ""

    cFil290 := " E2_RJ<>'X' AND E2_XDIVERG<>'S' "
    
Return cFil290