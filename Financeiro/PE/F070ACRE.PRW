#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} User Function F070ACRE
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
	@history Chamado 051017 - FWNM         - 09/09/2019 - estorno e cancelamento na mesma data baixa
	@history Chamado 053347 - FWNM         - 29/11/2019 - 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL
/*/
User Function F070ACRE

	//if cEmpAnt = '01' .or. cEmpAnt = '02' // Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - fwnm - 06/12/2019
		 nJuros    := SE1->E1_VALJUR
		 nAcresc   := SE1->E1_ACRESC
		 nAcrescF  := SE1->E1_ACRESC
		 nDecresc  := SE1->E1_DECRESC
		 nDecrescF := SE1->E1_DECRESC
	//endif
	
	// Chamado n. 051017 - Desenvolver tratativa no estorno e cancelamento na mesma data da baixa
	/*
	Ponto de Entrada para garantir que o campo 'Data Receb.'   
	contido na tela de baixa manual (FINA070) seja igual ao    
	campo 'Data Credito' e/ou igual a database do sistema.     
	*/
	dBaixa := dDataBase
	// 

Return()