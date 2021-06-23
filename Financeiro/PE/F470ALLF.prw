#include "rwmake.ch"
#include "protheus.ch"

/*/{Protheus.doc} User Function F470ALLF
	Este ponto de entrada permite a sinalização de que deve ser feito o  tratamento do extrato utilizando o filtro da filial corrente.A rotina de Extrato Bancario dispõe de tratamentos para que a filial do SE5 não seja filtrada caso quando 'SA6 exclusivo' e 'SE5 compartilhado'. Esse controle é feito garantir a integridade do Extrato Bancário.No entanto,  o cliente pode utilizar suas tabelas nessa configuração e ainda assim ter somente 1 filial ou todos os movimentos bancários na mesma filial. Para tal, foi disponibilizado um Ponto de Entrada para que possa ser sinalizado que quer o tratamento do extrato utilizando o filtro da filial corrente.
	@author William
    @since 22/07/2020
	@version 01
	
/*/

User Function F470ALLF()

    Local lAllFil := ParamIxb[1]
    Local lRet    := .T.

Return(lRet)
