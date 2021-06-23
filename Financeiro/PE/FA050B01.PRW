#Include "RwMake.ch"
#Include 'Protheus.ch'

/*/{Protheus.doc} User Function FA050B01
	Exclui divergencia da central de aprovacao quando o titulo PA for excluido
	@type  Function
	@author Ricardo Lima
	@since 21/11/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 038609
    @history Chamado TI     - Ricardo Lima - 28/03/2018 - Ajuste no índice de busca
	@history Chamado 053347 - FWNM         - 29/11/2019 - 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL
/*/
User Function Fa050b01()

	Local _aArea    := GetArea()

	//if cEmpAnt = '01' .or. cEmpAnt = '02' // Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - FWNM - 02/12/2019 
		DbSelectArea("ZC7")
		DbSetOrder(2)  // ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_TIPO
		If DbSeek( xFilial("ZC7") + M->E2_FORNECE + M->E2_LOJA + M->E2_PREFIXO + M->E2_NUM + M->E2_PARCELA + M->E2_TIPO ) // Ricardo Lima - 28/03/18
			If RecLock("ZC7",.f.)
				ZC7->(dbDelete())
				ZC7->(MsUnlock())
			Endif
		Endif
	//endif

	RestArea(_aArea)

Return()