#include "protheus.ch"

/*{Protheus.doc} User Function FA450BUT
	Garante uma unica thread por empresa
	@type  Function
	@author FWNM
	@since 31/10/2019
	@version 01
	@history Chamado 049953 - FWNM            - 31/10/2019 - 049953 || OS 051296 || CONTROLADORIA || MONIK_MACEDO || 8956 || CONTAB. IMBOLIZADO  
	@history Chamado TI     - FWNM            - 12/11/2019 - Tratamento para executar apenas quando entrar na rotina de compensacao entre carteiras, pois estava sendo executado ao clicar em Atualizacoes -> Contas a Pagar (antes mesmo do usuario chamar rotina - SIGAMDI)
	@history Chamado TI     - FWNM            - 13/11/2019 - Correcao inicializador aRotina com PARAMIXB
*/

User Function FA450BUT()

	Local cKeyBloq := "FINA450" // Compensacao entre carteiras
	Local aRotina  := ParamIxb[1] // Chamado TI     - FWNM            - 13/11/2019 - Correcao inicializador aRotina com PARAMIXB
	
	If IsInCallStack("FINA450") // Chamado TI     - FWNM            - 12/11/2019 - Tratamento para executar apenas quando entrar na rotina de compensacao entre carteiras, pois estava sendo executado ao clicar em Atualizacoes -> Contas a Pagar (antes mesmo do usuario chamar rotina - SIGAMDI)
		// Garanto uma única thread sendo executada
		If !LockByName(cKeyBloq, .T., .F.)
			msgAlert("[FA450BUT-01] - Existe outro processamento sendo executado! Aguarde ou peça para seu colega de trabalho fechar a rotina... Esta rotina será desconectada pelo administrador...")
			KillApp(.T.)
		EndIf
	EndIf
		
Return aRotina