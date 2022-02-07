#INCLUDE 'PROTHEUS.CH'


/*/
	{Protheus.doc} User Function NGTERMOT
	Ponto de entrada chamado para fazer alguma valida��o na finaliza��o de uma Ordem de Servi�o, antes de montar a tela.
    @author Andre Vinagre
    @since 27/08/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history Ticket 15804  - Rodrigo Rom�o  - 27/08/2021 - preparado rotina para enviar email por scheduled
/*/

User Function NGTERMOT()
	local lRet := .T.
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'P.E finaliza��o de uma Ordem de Servi�o, antes de montar a tela')
	
	lRet := u_MNT40011("NGTERMOT")

Return (lRet)
