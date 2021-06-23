#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} User Function ³F240AlMod
	Ponto de Entrada para alterar o conteudo do EA_MODELO na geracao do Sispag
	@type  Function
	@author WILLIAM COSTA
	@since 09/09/2019
	@history Ticket   7801 - Abel Babini - 08/01/2021 - Ajuste na busca de títulos pelo EA_FILORIG
	/*/

USER FUNCTION F240AlMod()
 
	LOCAL cModelo    := Paramixb[1]
	LOCAL cCodBarras := ''

	//Ticket   7801 - Abel Babini - 08/01/2021 - Ajuste na busca de títulos pelo EA_FILORIG	
	cCodBarras := Posicione("SE2",1,SEA->EA_FILORIG+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA+SEA->EA_TIPO+SEA->EA_FORNECE+SEA->EA_LOJA,"E2_CODBAR")
	                         
	IF ALLTRIM(cCodBarras) <> ''
	
		IF cModelo == "91"
		 
		   cModelo := "28"
		    
		ENDIF 
		 
	ENDIF
	
RETURN(cModelo)
