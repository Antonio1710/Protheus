#include "protheus.ch"

/*{Protheus.doc} User Function FA330MNU
	Garante uma unica thread por empresa
	@type  Function
	@author FWNM
	@since 31/10/2019
	@version 01
	@history Chamado 049953 - FWNM            - 31/10/2019 - 049953 || OS 051296 || CONTROLADORIA || MONIK_MACEDO || 8956 || CONTAB. IMBOLIZADO
	@history Chamado TI     - FWNM            - 13/11/2019 - Correcao inicializador aRotina com PARAMIXB  
*/

User Function FA330MNU()

	Local cKeyBloq := "FINA330" // Compensacao contas receber
	Local aRotina  := ParamIxb[1] // Chamado TI     - FWNM            - 13/11/2019 - Correcao inicializador aRotina com PARAMIXB
	
	// Garanto uma única thread sendo executada
	If !LockByName(cKeyBloq, .T., .F.)
		msgAlert("[FA330MNU-01] - Existe outro processamento sendo executado! Aguarde ou peça para seu colega de trabalho fechar a rotina... Esta rotina será desconectada pelo administrador...")
		KillApp(.T.)
	EndIf
		
Return aRotina