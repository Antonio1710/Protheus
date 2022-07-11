#Include "RwMake.ch"
#INCLUDE "PROTHEUS.CH" 

/*/{Protheus.doc} User Function MT410TRV
	Desativa travamento da SB2 do pedido de vendas
	@type  Function
	@author Ricardo Lima
	@since 04/05/18
	@version version
	@history Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	@history Ticket TI      - Abel Babini          - 11/07/2022 - Não faz o bloqueio da A1 e A2
	/*/
User Function MT410TRV()
 
	Local cCliForn := ParamIXB[1] // Codigo do cliente/fornecedor 
	Local cLoja    := ParamIXB[2] // Loja 
	Local cTipo    := ParamIXB[3] // C=Cliente(SA1) - F=Fornecedor(SA2) 
	Local aRet     := Array(4) 

	Local lTravaSA1 := .T. 
	Local lTravaSA2 := .T. 
	Local lTravaSB2 := .T. 
	Local lAtvPE := SuperGetMv( "MV_#MT410T" , .F. , .F. ,  )
	Local cEmpSF:= GetMv("MV_#SFEMP",,"01|") 		//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	Local cFilSF:= GetMv("MV_#SFFIL",,"02|0B|") 	//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI

	//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	If (Alltrim(cEmpAnt) $ cEmpSF .And. Alltrim(cFilAnt) $ cFilSF) .AND. lAtvPE

		lTravaSB2 := .F.  // Desliga trava da tabela SB2

		//Ticket TI      - Abel Babini          - 11/07/2022 - Não faz o bloqueio da A1 e A2
		lTravaSA1 := .F.  // Desliga trava da tabela SB2
		lTravaSA2 := .F.  // Desliga trava da tabela SB2

	endif 

	aRet[1] := lTravaSA1 
	aRet[2] := lTravaSA2 
	aRet[3] := lTravaSB2 

Return(aRet)
