#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} User Function F080ACRE
	Central Aprovação
	@type  Function
	@author Ricardo Lima
	@since 14/11/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 038609
	@history Chamado 053347 - FWNM         - 29/11/2019 - 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL
/*/
User Function F080ACRE

    //if cEmpAnt = '01' .or. cEmpAnt = '02' // Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - fwnm - 06/12/2019
    nJuros   := SE2->E2_VALJUR
    nDescont := SE2->E2_CNABDES
    nAcresc  := SE2->E2_ACRESC
    nAcrescF := SE2->E2_ACRESC
    // nDecresc := SE2->E2_DECRESC // Ricardo Lima - 10/03/18
    // nDecrescF := SE2->E2_DECRESC // Ricardo Lima - 10/03/18
    //endif

Return()