#Include "PROTHEUS.CH"

/*/{Protheus.doc} User Function 590/001
    Retorna o valor convertido em real.
    @type  Function
    @author Leonardo P. Monteiro
    @since 12/11/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history chamado 63633 - Leonardo P. Monteiro - 012/11/2021 - Correção dos valores em segunda moeda.
    @history chamado 63633 - Leonardo P. Monteiro - 012/11/2021 - Correção no campo de referência.
/*/
User Function LP597A()
Local _nValor  := 0
// SE5->E5_VALOR+U_LP597b("SE5","E5D")-U_LP597b("SE5","E5J")
U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

_nValor := iif(SE5->E5_MOEDA=='01' .or. SE5->E5_VLMOED2 == 0,SE5->E5_VALOR, SE5->E5_VLMOED2)
   
Return(_nValor)
