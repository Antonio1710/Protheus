#include "rwmake.ch"
#Include "Protheus.ch"
 
/*{Protheus.doc} User Function MA020MEM
	046516, Variavel Publica para controle de alteração de Campos no cadastro de fornecedor
	@type  Function
	@author Ricardo Lima
	@since 17/01/2019
	@version 01
    @Ticket 18071 - 21/06/2022 - Antonio Domingos - Melhoria no cadastro de fornecedor
*/
User function MA020MEM()

    Local cUsMemo     := ""
    Public lADRAltF   := .F.
    Public _lRetFld01 := .F.
    Public _lRetFld02 := .F.

Return( cUsMemo )
