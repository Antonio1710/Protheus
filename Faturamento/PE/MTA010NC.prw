#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

/*/{Protheus.doc} User Function MTA010NC
	Ponto Entrada que não devem ser copiados
	@type  Function
	@author William Costa
	@since 19/10/2018
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 045514 - William Costa - 05/12/2018 - || OS 046675 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || OP - Adicionado dois campos B1_CODBAR B1_LOCALIZ
	@history chamado 050729 - FWNM          - 01/07/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - Cópia Produto - Campo B1_COD2
/*/
USER FUNCTION MTA010NC()
	
	Local aCpoNC := {}
	
	AAdd( aCpoNC, 'B1_MSBLQL' )
	AAdd( aCpoNC, 'B1_CODBAR' )
	AAdd( aCpoNC, 'B1_LOCALIZ' )
	AAdd( aCpoNC, 'B1_COD2' ) // Chamado n. 050729 - FWNM - 01/07/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - Cópia Produto - Campo B1_COD2
		
Return (aCpoNC)