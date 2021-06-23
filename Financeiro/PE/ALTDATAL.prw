#Include 'Protheus.ch'

/*/{Protheus.doc} User Function ALTDATAL
	Ponto Entrada para contabilizar pelo E5_DTDISPO quando FINA070 (Bx Cr On-Line). 
	Antes foi aberto chamado onde a TOTVS confirmou que a contabilizacao on-line sempre será pela database.
	@type  Function
	@author Fernando Macieira
	@since 20/08/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Chamado 051148 - FWNM         - 20/08/2019 - 051148 || OS 052500 || CONTROLADORIA || MONIK_MACEDO || 8956 || DATA DISPONIBILIDADE
	@history Chamado 051528 - FWNM         - 04/09/2019 - 051528 || OS 052850 || FINANCAS || MARILIA || 8353 || ESTONO DE BAIXA
	@history Chamado 053573 - FWNM         - 25/11/2019 - 053573 || OS 054972 || CONTROLADORIA || CRISTIANE_MELO || 8441 || LP DE BAIXAS
/*/
User Function ALTDATAL()

	Local dDataLanc := paramixb[1] 
	Local cRotina   := paramixb[2]

    // Chamado TI || DATA DISPONIBILIDADE FINA740 - fwnm - 02/09/2019
	If IsInCallStack("FINA070") // Baixa a Receber Manual e Lote
		If Empty(cLoteFin)
			If Empty(SE5->E5_SITUACA) // Chamado n. 053573 || OS 054972 || CONTROLADORIA || CRISTIANE_MELO || 8441 || LP DE BAIXAS - fwnm - 25/11/2019
				//dDataLanc := dDtCredito // Chamado n. 051528 || OS 052850 || FINANCAS || MARILIA || 8353 || ESTONO DE BAIXA - fwnm - 04/09/2019
				dDataLanc := SE5->E5_DTDISPO // Chamado n. 051528 || OS 052850 || FINANCAS || MARILIA || 8353 || ESTONO DE BAIXA - fwnm - 04/09/2019
			EndIf
		EndIf
	EndIf                                                            

	If IsInCallStack("FINA110") // Baixas Automaticas de Titulos a Receber  
		If Empty(SE5->E5_SITUACA) // Chamado n. 053573 || OS 054972 || CONTROLADORIA || CRISTIANE_MELO || 8441 || LP DE BAIXAS - fwnm - 25/11/2019
			dDataLanc := dDtCredito
		EndIf
	EndIf                                                            
	//

Return dDataLanc