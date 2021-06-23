#include "protheus.ch"

/*/{Protheus.doc} User Function F430Rej
	Ponto Entrada Retorno Pagamento Executado quando EB_OCORR = 03 (Titulo rejeitado)
	@type  Function
	@author Fernando Macieira
	@since 07/11/2019
	@version version
	@history Chamado 052705 || OS 054094 || FINANCAS || FLAVIA || 8461 || RETONO BANCO IDCNAB
	/*/

User Function F430REJ()

	Local cE2IDCNAB := SE2->E2_IDCNAB
	Local cE2Hist   := AllTrim(SE2->E2_HIST)

	If !Empty(cE2IDCNAB)

		RecLock("SE2", .F.)
			SE2->E2_HIST   := cE2IDCNAB + cE2Hist
			SE2->E2_IDCNAB := ""
		SE2->( msUnLock() )
	
	EndIf

Return