#INCLUDE "Protheus.ch"

/*/{Protheus.doc} User Function MT170SC1
	Ponto de entrada executado na rotina Solicitação de compra por ponto de pedido. Faz a atualização do item contabil centro de custo e observacao
	@type  Function
	@author WILLIAM COSTA
	@since 23/02/2018
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 71057 - Fernando Macieira - 08/04/2022 - Item contábil Lançamentos da Filial 0B - Itapira
/*/
USER FUNCTION MT170FIM()

	LOCAL _aArea := GetArea()   
	LOCAL aScs   := PARAMIXB[1]
	LOCAL nCont  := 0
	Local cMVItemCta := AllTrim(GetMV("MV_#ITAFIL",,"125"))
	
	For nCont:= 1 To LEN(aScs)    
	
		DBSELECTAREA('SC1')    
		DBGOTOP()
		DBSETORDER(2)
		IF DBSEEK(XFILIAL('SC1')+aScs[nCont,1]+aScs[nCont,2])
		
			RECLOCK('SC1',.F.)        
			
				If AllTrim(cEmpAnt) == "01"
					// @history ticket 71057 - Fernando Macieira - 08/04/2022 - Item contábil Lançamentos da Filial 0B - Itapira
					If AllTrim(cFilAnt) == AllTrim(cMVItemCta)
						SC1->C1_ITEMCTA := cMVItemCta
					// 
					Else
						IF cFilant == "02"
							SC1->C1_ITEMCTA := "121"
						ELSEIF cFilant == "03"
							SC1->C1_ITEMCTA := "114"
						ENDIF
					EndIf
				EndIf
				//

				SC1->C1_CC      := '8001'
				SC1->C1_OBS     := 'SC gerada por ponto de pedido'
				SC1->C1_XHORASC := TIME()
				SC1->C1_XGRCOMP := '1'
				SC1->C1_LOCAL   := IIF(!RetArqProd(SC1->C1_PRODUTO),POSICIONE("SBZ",1,xFilial("SBZ")+SC1->C1_PRODUTO,"BZ_LOCPAD"),POSICIONE("SB1",1,xFilial("SB1")+SC1->C1_PRODUTO,"B1_LOCPAD"))
				SC1->C1_DATPRF  := DATE() + IIF(!RetArqProd(SC1->C1_PRODUTO),POSICIONE("SBZ",1,xFilial("SBZ")+SC1->C1_PRODUTO,"BZ_PE"),POSICIONE("SB1",1,xFilial("SB1")+SC1->C1_PRODUTO,"B1_PE")) // chamado 041329 WILLIAM COSTA         
			MsUnlock()     
		ENDIF
	NEXT
	
	RestArea( _aArea )
	
RETURN(NIL)
