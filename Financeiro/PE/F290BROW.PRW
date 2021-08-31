#include "protheus.ch"

/*{Protheus.doc} User Function F290BROW
	Esta contabilização não é realizada Off-Line, conforme link abaixo:
	http://tdn.totvs.com/pages/releaseview.action?pageId=145362219
	Garante uma unica thread por empresa
	@type  Function
	@author FWNM
	@since 21/08/2019
	@version 01
	@history Chamado 051145 - FWNM            - 21/08/2019 - 051145 || OS 052497 || CONTROLADORIA || MONIK_MACEDO || 8956 || LP 530 E LP 532    
	@history Chamado 049953 - FWNM            - 31/10/2019 - 049953 || OS 051296 || CONTROLADORIA || MONIK_MACEDO || 8956 || CONTAB. IMBOLIZADO  
	@history Ticket   18927 - Sigoli          - 30/08/2021 - Alterado parametro do LockByName para controlar Empresa+Filial
*/

User Function F290BROW()

	Local cPergAux := "AFI290"
	Local cKeyBloq := "FINA290" // Fatura a pagar

	// Garanto uma unica thread sendo executada por empresa
	//If !LockByName(cKeyBloq, .T., .F.)
	If !LockByName(cKeyBloq, .T., .T.) //Tkt 18927 - Sigoli - 26/08/2021alteradao para cotrolar Empresa+filial
		msgAlert("[F290BROW-01] - Existe outro processamento sendo executado! Aguarde ou peça para seu colega de trabalho fechar a rotina... Esta rotina será desconectada pelo administrador...")
		KillApp(.T.)
	EndIf

	cPergAux := PadR(cPergAux, Len(SX1->X1_GRUPO))
		
	Pergunte(cPergAux, .f.)
	
	MV_PAR03 := 1
	MV_PAR04 := 1

Return
