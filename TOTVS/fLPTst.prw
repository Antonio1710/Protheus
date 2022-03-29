#include "protheus.ch"

/*/{Protheus.doc} User Function nomeFunction
    (long_description)
    @type  Function
    @author user
    @since 23/03/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function fLPTst()

    Local nVlr   := 0

    u_GrLogZBE ( msDate(), Time(), cUserName, ALLTRIM(SD3->D3_TM), ALLTRIM(SD3->D3_DOC), "FLPTST", ALLTRIM(SD3->D3_GRUPO), ALLTRIM(SD3->D3_LOCAL), ALLTRIM(SD3->D3_CF) )

    If ALLTRIM(SD3->D3_TM)=="499"      .AND.;
        ALLTRIM(SD3->D3_LOCAL)=="03"   .AND.;
        ALLTRIM(SD3->D3_CF)=="DE0"     .AND.; 
        ALLTRIM(SD3->D3_DOC)=="RATEIO" .AND.; 
        ALLTRIM(SD3->D3_GRUPO)$"9006|9007|9037"

        nVlr := SD3->D3_CUSTO1

    EndIf
    
Return nVlr

/*/{Protheus.doc} User Function nomeFunction
    (long_description)
    @type  Function
    @author user
    @since 28/03/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function fLP588()

    Local lDebug := .t.
    Local nVlr := 0

    nVlr := SE5->E5_VALOR
    
Return nVlr
