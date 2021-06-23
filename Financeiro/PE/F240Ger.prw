#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function F240GER
    O ponto de entrada F240GER faz a verificação e permite gerar ou não o SISPAG. Para maiores informações, consulte: http://tdn.totvs.com/pages/releaseview.action?pageId=6070989
    @type  Function
    @author FWNM
    @since 08/09/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket 99 - FWNM - 08/09/2020 - PROJETO PAGAR
/*/
User Function F240Ger()

    Local lF240Ger := .t.
    Local lCNABOn  := GetMV("MV_#CNABON",,.T.)

    // Chama função que consiste os borderôs para gerar ou não o arquivo de CNAB
    If lCNABOn
        msAguarde( { || lF240Ger := u_ADFIN100P("FINA300") }, "Regras de bloqueios - Consistindo borderôs" )
    EndIf

Return lF240Ger
