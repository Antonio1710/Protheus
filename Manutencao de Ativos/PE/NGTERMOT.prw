#INCLUDE 'PROTHEUS.CH'


/*/
	{Protheus.doc} User Function NGTERMOT
	Ponto de entrada chamado para fazer alguma validação na finalização de uma Ordem de Serviço, antes de montar a tela.
    @author Andre Vinagre
    @since 27/08/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history Ticket 15804  - Rodrigo Romão  - 27/08/2021 - preparado rotina para enviar email por scheduled
/*/

User Function NGTERMOT()
	local lRet := .T.

	lRet := u_MNT40011("NGTERMOT")

Return (lRet)
