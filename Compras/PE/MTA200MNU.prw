#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "REPORT.CH"

/*/{Protheus.doc} User Function MTA200MNU
    Ponto Entrada adicionar botão no cadastro de estrutura 
    @type  Function
    @author Fernando Macieira
    @since 06/10/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references) 
    @ticket 11639 - Projeto - OPS Documento de entrada
/*/
User Function MTA200MNU()

    aAdd( aRotina, { "* Importa XLS", "U_ADCON019P()", 0, 5, , .F. } )
    
Return aRotina
