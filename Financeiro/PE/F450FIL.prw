#include "protheus.ch"

/*/{Protheus.doc} User Function ³F450FIL
	Descricao ³Ponto de Entrada F450FIL, utilizado na compensacao entre
	Carteiras. Decisao de desenvolver para nao depender do F12.
	@type  Function
	@author Fernando Macieira
	@since 29/07/2019
	@version 01
	@history Chamado 048895 || OS 050173 || FINANCAS || LIGIA || 8479 || || COMPENSACOES X BORDEAP. 
	@history Ticket  9080 - Leonardo P. Monteiro - 05/02/2021 - Adiciona ao filtro a condição se já houve a compensação do borderô no título. Assim, possibilita a compensação entre carteiras do saldo restante.
	/*/
User Function F450FIL()

	Local c450Fil := ""
	
	//Ticket  9080 - Leonardo P. Monteiro - 05/02/2021 - Adiciona ao filtro a condição se já houve a compensação do borderô no título. Assim, possibilita a compensação entre carteiras do saldo restante.                                             
	//c450Fil += " AND SE1.E1_NUMBOR='' "
	c450Fil += " AND (SE1.E1_NUMBOR  = '' OR " 
	c450Fil += " 	 (SE1.E1_NUMBOR != '' "
	c450Fil += " 		AND EXISTS(SELECT SE5.E5_DOCUMEN "
	c450Fil += " 				   FROM "+ RetSqlName("SE5") +" SE5 "
	c450Fil += " 				   WHERE SE5.D_E_L_E_T_='' AND SE5.E5_FILIAL=SE1.E1_FILIAL AND SE5.E5_PREFIXO=SE1.E1_PREFIXO AND SE5.E5_NUMERO=SE1.E1_NUM AND "
	c450Fil += " 						 SE5.E5_PARCELA=SE1.E1_PARCELA AND SE5.E5_TIPO=SE1.E1_TIPO AND SE5.E5_CLIFOR=SE1.E1_CLIENTE AND SE5.E5_LOJA=SE1.E1_LOJA AND "
	c450Fil += " 						 SE5.E5_DOCUMEN=SE1.E1_NUMBOR AND SE5.E5_SITUACA=''))) "

Return c450Fil
