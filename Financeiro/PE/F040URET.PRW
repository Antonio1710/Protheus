#Include "RwMake.ch"
#include "protheus.ch"

/*/{Protheus.doc} User Function F040URET
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
	@history Chamado 053347 - FWNM     - 29/11/2019 - 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL
    @history chamado 058216 - FWNM     - 15/05/2020 - OS 059676 || FINANCAS || LUIZ || 8451 || CONTAS APAGAR
/*/
User Function F040URET()

	Local aRet := {}                      
	
	//if cEmpAnt = '01' .or. cEmpAnt = '02' // Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - fwnm - 06/12/2019
	If FunName() $ "FINA750|FINA050|FINA290|FINA080|FINA240"
		
        aAdd(aRet,{"E2_XDIVERG=='S' .or. E2_RJ=='X'","BR_MARROM"})
	
	ElseIf FunName() $ "FINA070|FINA040|FINA110|FINA330|FINA740"
		
        aAdd(aRet,{"E1_XDIVERG=='S'","BR_MARROM"})
	
	Endif

Return aRet