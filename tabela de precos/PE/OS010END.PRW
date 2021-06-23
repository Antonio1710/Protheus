#include "protheus.ch"
/*
// ##########################################################################################
// Modulo : SIGAFIN
// Fonte  : OS010END
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 07/03/18 | Ricardo Lima      | Atualiza Tabela de Preco no SalesForce     | 
// ---------+-------------------+--------------------------------------------+---------------
//          |                   |                                            |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
*/
User Function OS010END

	Local cTp 		:= PARAMIXB[1] 
	Local cOpc		:= PARAMIXB[2]
	Local cTabela 	:= "" //Criar MV.
	
	//
	If cEmpAnt == "01" .And. cFilAnt == "02"
	
		If FindFunction("U_ADVEN072P") .And. cTp = 1 .And. Alltrim(cValToChar(DA0->DA0_CODTAB )) == "2"
			U_ADVEN072P( DA0->DA0_CODTAB , DA0->DA0_CODTAB ,.F.,"")
			
		EndIf
		
		cTabela := "Y00/Z01"
		If FindFunction("U_ADVEN073P") .And. cTp = 1 .And. (Alltrim(cValToChar(DA0->DA0_CODTAB )) $cTabela)	
			U_ADVEN073P( DToS(Date()), DToS(Date()),.F.,"",.T.)
			
		EndIf
	
	EndIf

Return