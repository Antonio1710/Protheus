#Include "RwMake.ch"
#INCLUDE "PROTHEUS.CH" 
// ###############################################################################################
// Modulo : SIGAFAT
// Fonte  : MT410TRV
// ---------+-------------------+-------------------------------------------------+---------------
// Data     | Autor             | Descricao                                       | Chamado
// ---------+-------------------+-------------------------------------------------+---------------
// 04/05/18 | Ricardo Lima      | Desativa travamento da SB2 do pedido de vendas  | 
// ---------+-------------------+-------------------------------------------------+---------------
// ###############################################################################################

User Function MT410TRV()
 
Local cCliForn := ParamIXB[1] // Codigo do cliente/fornecedor 
Local cLoja    := ParamIXB[2] // Loja 
Local cTipo    := ParamIXB[3] // C=Cliente(SA1) - F=Fornecedor(SA2) 
Local aRet     := Array(4) 

Local lTravaSA1 := .T. 
Local lTravaSA2 := .T. 
Local lTravaSB2 := .T. 
Local lAtvPE := SuperGetMv( "MV_#MT410T" , .F. , .F. ,  )


if cEmpAnt == '01' .AND. cFilAnt == '02' .AND. lAtvPE

	lTravaSB2 := .F.  // Desliga trava da tabela SB2
	
endif 

aRet[1] := lTravaSA1 
aRet[2] := lTravaSA2 
aRet[3] := lTravaSB2 

Return(aRet)