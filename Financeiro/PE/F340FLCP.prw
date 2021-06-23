/*/{Protheus.doc} User Function F340FLCP
	Validação para não permitir compensar títulos em borderô
	@type  Function
	@author Abel Babini
	@since 11/09/2020
	@version 01
	@history Chamado    712 - O ponto de entrada F340COMP possibilita incluir validação para permitir compensar o tí­tulo selecionado ou não
*/

User Function F340FLCP 
  
  Local cNcompen := GetMV("MV_#NCOMP",,"PA,")
  Local cRet := " AND (SE2.E2_NUMBOR = '" + SPACE(TamSX3("E2_NUMBOR")[1]) + "'  AND SE2.E2_TIPO NOT IN "+FormatIn(cNcompen,',')+") "

Return cRet
