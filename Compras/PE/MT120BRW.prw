#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} User Function MT120BRW
	Ponto Entrada para chamar conteudo do campo memo
	@type  Function
	@author William Costa
	@since 27/12/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@Chamado 038389
	@Chamado 043195 - Abel Babini Filho - 23/09/2019 - Cria rotina de solicitacao de PA no menu
	@Chamado 053357 - FWNM              - 18/11/2019 - Chamada da rotina ADCOM032P que visa acertar PC encerrados mesmo qdo NF estornadas/excluidas
/*/
User Function MT120BRW()

	// Chamado n. 053357 || OS 054728 || FISCAL || ELIZABETE || 8424 || PEDIDO COM SALDO
	Local lUsrAut  := GetMV("MV_#ATVUSR",,.t.) // Ativa controle de usuarios autorizados
	Local cUsrAut  := GetMV("MV_#USRAUT",,"000000") // Usuarios autorizados
	//	

	aadd(aRotina,{"Ver Memo"				,"U_ADCOM018P()", 0 , 6,0,NIL})
	aadd(aRotina,{"Solicita PA"				,"U_ADFIN081P()", 0 , 6,0,NIL}) //Ch.043195 - 23/09/2019 - Abel Babini Filho|Apenas validar parametro de usuário caso o mesmo n
	
	// Chamado n. 053357 || OS 054728 || FISCAL || ELIZABETE || 8424 || PEDIDO COM SALDO
	If lUsrAut
		If AllTrim(RetCodUsr()) $ AllTrim(cUsrAut)
			aAdd(aRotina,{"PCs Encerrados x NFs "   ,"U_ADCOM032P()", 0 , 6,0,NIL}) 
		EndIf
	EndIf
	//

Return