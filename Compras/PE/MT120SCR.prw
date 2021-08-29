#Include "Protheus.ch"

/*/{Protheus.doc} User Function MT120SCR
    Ponto de entrada para limpeza de determinados campos na cópia do pedido.
    @type  Function
    @author Leonardo P. Monteiro
    @since 08/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history Chamado 15804  - Leonardo P. Monteiro  - 08/07/2021 - Grava informações adicionais do Pedido de Compra.
/*/

user function MT120SCR()
	local nX := 1

	if isInCallStack("A120Copia")
		for nX := 1 to len(aCols)
			gdFieldPut("C7_XSOLIC"	, "", nX)
			gdFieldPut("C7_XDTENTR"	, SToD(""), nX)
			gdFieldPut("C7_XRAZAO"	, "", nX)
			gdFieldPut("C7_XEST"	, "", nX)
            gdFieldPut("C7_XMUN"	, "", nX)
			
		next nX
	endIf
return
