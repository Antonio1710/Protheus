#Include "Totvs.ch"

/*/{Protheus.doc} CEXMGICTE
@description 	Ponto de entrada para gravacao de Itens do CT-e
@Obs			Permite retornar a quantidade de itens a ser gravado no CT-e
@author 		Fabrica de Software (Fabritech)
@since 			12/12/2019
@version		1.0
@return			Nil
@type 			Function
@history Chamado 054092 - Fernando Sigoli - 12/12/2019 - tratamento para segmentação/separação de cte por tipo de entrada - VENDA ou COMPRAS
/*/

User Function CEXMGICTE()
	
	Local aParans	:= PARAMIXB
	Local nIteCTE   := 0  
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'CENTRALXML- P.E para gravacao de Itens do CT-e ')
	
	//Para fretes de venda, nao quebrar em itens por xml, sempre retornar 1 Item na acols consolidado.
	If aParans[ 01 ] == "VENDA"
		nIteCTE	:= 1 
		
	//Caso seja outro tipo de Frete, retorna o Array original (quantidade de chaves no xml)
	Else
		nIteCTE	:= Len( aParans[ 02 ] )
	
	EndIf
	
Return nIteCTE