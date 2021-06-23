#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "Totvs.ch"

/*/{Protheus.doc} User Function M103DSE2
	Exclui divergencia na exclusão da nota
	@type  Function
	@author Ricardo Lima
	@since 27/12/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 038613
	@history Chamado 053347 - FWNM         - 29/11/2019 - 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL
/*/
User Function M103DSE2()

	Local _aArea    := GetArea()

	//if cEmpAnt = '01' .or. cEmpAnt = '02' // Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - FWNM - 02/12/2019 

	DbSelectArea("ZC7")
	DbSetOrder(2)  // ZC7_FILIAL+ZC7_CLIFOR+ZC7_LOJA+ZC7_PREFIX+ZC7_NUM+ZC7_PARCEL
	If DbSeek( xFilial("ZC7") + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA )
		
		If RecLock("ZC7",.f.)
			ZC7->(dbDelete())
			ZC7->(MsUnlock())
		Endif

	Endif

	//endif
	RestArea(_aArea)

Return