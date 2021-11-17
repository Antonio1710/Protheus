#Include "rwmake.ch"

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
/*/
User Function LP597A()    

Local nVlrTmp  := 0
Local _nValor  := 0
// SE5->E5_VALOR+U_LP597b("SE5","E5D")-U_LP597b("SE5","E5J")
U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

_nValor := iif(SE2->E2_MOEDA==1 .or. SE2->E2_VLCRUZ == 0,SE2->E2_VALOR, SE2->E2_VLCRUZ)
   
Return(_nValor)
