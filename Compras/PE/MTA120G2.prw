#INCLUDE "rwmake.ch"
/*/{Protheus.doc} User Function MTA120G2 
	Ponto de Entrada para gravar campo C7_PROJETO no Pedido de
	Compras. Chamado 004603.
	@type  Function
	@author MAURICIO-HC Consys
	@since 06/07/2009
	@version 01
	@history Everson, 04/11/2020. Chamado 2562. Tratamento para gravar o número do estudo do projeto.
	/*/
User Function MTA120G2
Local _cAreaSC1

_cAreaSC1 := GetArea()

if cEmpAnt == "01"

	DBselectarea("SC1")
	dbSetOrder(1)
	DBseek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC)
	if found()
		If Empty(SC7->C7_PROJETO)
			If !EMPTY(SC1->C1_PROJADO)
				RecLock("SC7",.F.)
				Replace SC7->C7_PROJETO With SC1->C1_PROJADO            
				MsUnlock("SC7") 
			Endif	
		Endif
		If Empty(SC7->C7_CODPROJ)
			If !EMPTY(SC1->C1_CODPROJ)
				RecLock("SC7",.F.)
				Replace SC7->C7_CODPROJ With SC1->C1_CODPROJ            
				MsUnlock("SC7") 
			Endif	
		Endif

		//Everson - 04/11/2020. Chamado 2562.
		If Empty(SC7->C7_XITEMST)
			If !EMPTY(SC1->C1_XITEMST)
				RecLock("SC7",.F.)
				Replace SC7->C7_XITEMST With SC1->C1_XITEMST            
				MsUnlock("SC7") 
			Endif	
		Endif
		//

	Endif
Endif

RestArea(_cAreaSC1)          
Return
