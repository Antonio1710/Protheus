#include "rwmake.ch"   
#include "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH" 

/*/{Protheus.doc} User Function FA070CHK
	Central de Aprovação
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
User Function FA070CHK

	Local _lRet := .T.

	//if cEmpAnt = '01' .or. cEmpAnt = '02' // Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - fwnm - 06/12/2019
	If SE1->E1_XDIVERG == 'S' 
		MsgInfo("Titulo Com divergencia, Necessário Aprovação!", "Informacao")
		_lRet		:= .F.
	ENDIF	
	//endif

Return( _lRet )