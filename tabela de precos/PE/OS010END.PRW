#include "protheus.ch"
/*
// ##########################################################################################
// Modulo : SIGAFIN
// Fonte  : OS010END
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 07/03/18 | Ricardo Lima      | Atualiza Tabela de Preco no SalesForce     | 
@history Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
*/
User Function OS010END
	Local cFilSF:= GetMv("MV_#SFFIL",,"02|0B|") 	//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	Local cEmpSF:= GetMv("MV_#SFEMP",,"01|") 		//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI

	Local cTp 		:= PARAMIXB[1] 
	Local cOpc		:= PARAMIXB[2]
	Local cTabela 	:= "" //Criar MV.
	
	//
	If Alltrim(cEmpAnt) $ cEmpSF .And. Alltrim(cFilAnt) $ cFilSF
	
		If FindFunction("U_ADVEN072P") .And. cTp = 1 .And. Alltrim(cValToChar(DA0->DA0_CODTAB )) == "2"
			U_ADVEN072P( DA0->DA0_CODTAB , DA0->DA0_CODTAB ,.F.,"")
			
		EndIf
		
		cTabela := "Y00/Z01"
		If FindFunction("U_ADVEN073P") .And. cTp = 1 .And. (Alltrim(cValToChar(DA0->DA0_CODTAB )) $cTabela)	
			U_ADVEN073P( DToS(Date()), DToS(Date()),.F.,"",.T.)
			
		EndIf
	
	EndIf

Return
