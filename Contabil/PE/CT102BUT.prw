#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function CT102BUT 
    Ponto de Entrada que permite adicionar novos bot�es para o array arotina, no menu da mbrowse em lan�amentos cont�beis autom�ticos.
    @type  Function
    @author Fernando Macieira
    @since 29/09/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 53785 - Log inclus�o/ Altera��o - Protheus
/*/
User Function CT102BUT()

    Local aBotao := {}
    
    aAdd( aBotao, { '* Log Inclus�o/Altera��o',"u_LogCT2", 0, 3 })
    
Return(aBotao)

/*/{Protheus.doc} User Function LogCT2
    (long_description)
    @type  Function
    @author FWNM
    @since 29/09/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function LogCT2()

    Local cIncLog := USRFULLNAME(SUBSTR(EMBARALHA(CT2->CT2_USERGI,1),3,6))
    Local cAltLog := USRFULLNAME(SUBSTR(EMBARALHA(CT2->CT2_USERGA,1),3,6))

    msgAlert( "Inclus�o: " + cIncLog + Chr(13)+Chr(10) + " Altera��o: " + cAltLog )
    
Return 
