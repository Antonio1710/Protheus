/*/{Protheus.doc} User Function ADFIN133P
	Validação de placa para verificar vinculo com a transportadora
	@type  Function
	@author Jonathan Carvalho
	@since 07/06/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
    @ticket 72807 - Jonathan Carvalho - 07/06/2022 verificação de vinculo entre placa e transportadora
	/*/

User Function ADFIN133P()
	Local lRet := .F.
	
	//Procura pela placa + transportadora
	DbSelectArea("ZV4")
	ZV4->(dbSetOrder(1))
	if ZV4->(dbseek(xFilial("ZV4")+Alltrim(M->C5_PLACA))) .AND. ZV4->ZV4_FORNEC == M->C5_TRANSP 

		lRet := .T.
	else
		MsgInfo('Placa não vinculada com a Transportadora', 'Atenção')
	Endif
	
    
Return //lRet
