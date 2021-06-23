#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function FA420CRI
    Ponto Entrada FA420CRI tem como finalidade permitir a criação do arquivo de envio CNAB a pagar e será executado antes de criar o arquivo de envio.
    @type  Function
    @author FWNM
    @since 01/09/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket 99 - FWNM - 01/09/2020 - PROJETO PAGAR
/*/
User Function FA420CRI()

    Local lFa420CRI := .t.
    Local lCNABOn  := GetMV("MV_#CNABON",,.T.)

    // Chama função que consiste os borderôs para gerar ou não o arquivo de CNAB
    If lCNABOn
        msAguarde( { || lFa420CRI := u_ADFIN100P("FINA420") }, "Regras de bloqueios - Consistindo borderôs" )
    EndIf

Return lFa420CRI
