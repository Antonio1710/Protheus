#include "protheus.ch"

/*{Protheus.doc} User Function F090BROW
	Garante uma unica thread por empresa
	@type  Function
	@author FWNM
	@since 31/10/2019
	@version 01
	@history Chamado 049953 - FWNM            - 31/10/2019 - 049953 || OS 051296 || CONTROLADORIA || MONIK_MACEDO || 8956 || CONTAB. IMBOLIZADO  
*/

User Function F090BROW()   

	Local cKeyBloq := "FINA090" // Baixa pagar automatica e multi-filiais

	// Garanto uma unica thread por empresa sendo executada
	If !LockByName(cKeyBloq, .T., .F.)
		msgAlert("[F090BROW-01] - Existe outro processamento sendo executado! Aguarde ou peça para seu colega de trabalho fechar a rotina... Esta rotina será desconectada pelo administrador...")
		KillApp(.T.)
	EndIf
		
Return