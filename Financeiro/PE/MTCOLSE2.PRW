#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function MTCOLSE2
    Ponto Entrada para consistir folder duplicatas do documento entrada apenas na CENTRAL XML
    Carrega variavel publica __MTCOLSE2 para ser utilizada no PE MT100TOK
    @type  Function
    @author Fernando Macieira
    @since 26/11/2019
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history Chamado 053639 || OS 055007 || FISCAL || DEJAIME || 8921 || ENTRADA X DUPLICATAS
/*/
User Function MTCOLSE2()

    Local i
    Local nTtSE2 := 0
    Local aParam := PARAMIXB[1]

    Public __MTCOLSE2 := 0 // Será utilizada no MT100TOK pois a central XML não executa todos os PEs contidos no MATA103 - Exemplo A1031DUP

    // Acho valor total das duplicatas no acols do folder duplicatas
    For i:=1 to Len(aParam)
        nTtSE2 += aParam[i,3]
    Next i

    __MTCOLSE2 := nTtSE2 // Variavel publica para ser utilizada no MT100TOK
    
Return