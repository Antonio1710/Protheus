/*/{Protheus.doc} User Function F340FLCP
	Valida��o para n�o permitir compensar t�tulos em border�
	@type  Function
	@author Abel Babini
	@since 11/09/2020
	@version 01
	@history Chamado    712 - O ponto de entrada F340COMP possibilita incluir valida��o para permitir compensar o t�tulo selecionado ou n�o
*/

User Function F340FLCP 
  
  Local cNcompen := GetMV("MV_#NCOMP",,"PA,")
  Local cRet := " AND (SE2.E2_NUMBOR = '" + SPACE(TamSX3("E2_NUMBOR")[1]) + "'  AND SE2.E2_TIPO NOT IN "+FormatIn(cNcompen,',')+") "

Return cRet
