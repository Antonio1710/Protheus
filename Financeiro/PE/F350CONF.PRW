#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} User Function F340VALOK
	Valida a execução da correção monterária e garante que os parâmetros estão corretos.
	@type  Function
	@author Leonardo P. Monteiro
	@since 07/01/2021
	@version 01
	@history Chamado   7690 - LPM		   - 07/01/2021 - Chamado 7690||OS ||Financeiro||Wagner Ferreira||RAMAL|| Ponto de entrada para validação da rotina Correção Monetária e garantir que os parâmetros estão de acordo com as regras Ad'oro."
*/

User Function F350CONF()
    Local lRet      := .T.
    Local dUltDia   := LastDay(dDatabase)
    
    If dUltDia != dDatabase
        Msginfo("A rotina 'Correção Monetária'(FINA350) somente pode ser executada com a DATABASE do sistema no último dia do mês "+ Dtoc(dUltDia) +".")
        
        lRet := .F.
        MsgAlert("A rotina 'Correção Monetária'(FINA350) não foi executada!" )
    Elseif MV_PAR08 == 0 .OR. MV_PAR09 == 0
        Msginfo("Os campos 'Taxa de Venda' e 'Taxa de Compras' precisam ser informados para a execução do cálculo.")
        
        lRet := .F.
    Else
        lRet := .T.
    Endif 
 
return lRet
