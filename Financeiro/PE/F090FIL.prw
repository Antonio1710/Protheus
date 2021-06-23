#include "protheus.ch"

/*/{Protheus.doc} User Function F090FIL
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
    @history chamado n. 058216 || OS 059676 || FINANCAS || LUIZ || 8451 || CONTAS APAGAR
    @history chamado n. 060061 - Abel Babini - 04/08/2020 - Ajuste no Filtro que causava erro na rotina.
/*/
User Function F090FIL()
    //INICIO chamado n. 060061 - Abel Babini - 04/08/2020 - Ajuste no Filtro que causava erro na rotina.
    //Local cFil090 := ""
    Local cFil090:= PARAMIXB[7]  //recebe a cláusula WHERE atual da rotina

    //cFil090 := " SE2->E2_RJ<>'X' .AND. SE2->E2_XDIVERG<>'S' "
    cFil090 += " AND E2_RJ<>'X' AND E2_XDIVERG<>'S' "
    //FIM chamado n. 060061 - Abel Babini - 04/08/2020 - Ajuste no Filtro que causava erro na rotina.
Return cFil090
