#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function GPM060EX
    Ponto Entrada Integração Título
    @type  Function
    @author Fernando Macieira
    @since 06/02/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 055575 || OS 056974 || CONTROLADORIA || TAMIRES_SERAFIM || 8503 || TITULO R.H
   	@history Chamado 546 - Adriana Oliveira	- 31/08/2020 - Exclusao TITULO no SE2, por rotina automatica
/*/
User Function GPM060EX()

    Local lRet := .t.
    Local dMVDataFin := GetMV("MV_DATAFIN")
    Local aAreaSE2 := SE2->( GetArea() )
	
	SE2->( dbSetOrder(6) ) // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
    If SE2->( dbSeek(RC1->(RC1_FILTIT+RC1_FORNECE+RC1_LOJA+RC1_PREFIX+RC1_NUMTIT)) )
        If SE2->E2_EMISSAO < dMVDataFin
            lRet := .f.
            Alert("[GPM060EX-01] - Título n. " + SE2->E2_NUM + " no financeiro não poderá ser excluído pois a data de emissão está menor que a data do parâmetro MV_DATAFIN! Contate a contabilidade...")
    
        else // Inicio Chamado 546 - Adriana Oliveira	- 31/08/2020
            If _ExcSE2()
                Alert("[GPM060EX-02] - Título n. " + RC1->RC1_NUMTIT + " excluído no financeiro.")
 
            Else
                Alert("[GPM060EX-03] - Título n. " + RC1->RC1_NUMTIT + " não foi possível excluir no financeiro.")
                lRet := .f.
            Endif
            // Fim Chamado 546 - Adriana Oliveira	- 31/08/2020
        EndIf
    
    EndIf

    RestArea( aAreaSE2 )
    
Return lRet

/*/{Protheus.doc} Static Function _ExcSE2
	Exclui titulo por rotina automatica FINA050
	@type  Static Function
	@author Adriana Oliveira
	@since 31/08/2020
	@history Chamado 546
*/
Static Function _ExcSE2
Local aArray    := {}
Local lExc      := .T.
Private lMsErroAuto := .F.
 
aArray := { { "E2_PREFIXO" , SE2->E2_PREFIXO , NIL },;
                { "E2_NUM"     , SE2->E2_NUM     , NIL } }
 
MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 5)  // 5 - Exclusão
 
If lMsErroAuto
	DisarmTransaction()
	Mostraerro()
	lExc:=.F.
Else
	lExc:=.T.
EndIf			
 
Return lExc
