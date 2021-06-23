#INCLUDE "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT170SC1  �Autor  �WILLIAM COSTA       � Data �  23/02/2018 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada executado na rotina Solicita��o de compra ���
���          � por ponto de pedido. Faz a atualiza��o do item contabil    ���
���          � centro de custo e observacao                               ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER FUNCTION MT170FIM()

	LOCAL _aArea := GetArea()   
	LOCAL aScs   := PARAMIXB[1]
	LOCAL nCont  := 0
	
	For nCont:= 1 To LEN(aScs)    
	
		DBSELECTAREA('SC1')    
		DBGOTOP()
		DBSETORDER(2)
		IF DBSEEK(XFILIAL('SC1')+aScs[nCont,1]+aScs[nCont,2])        
		
			RECLOCK('SC1',.F.)        
			
				IF cFilant == "02"
		
					SC1->C1_ITEMCTA := "121"
					
				ELSEIF cFilant == "03"
				
					SC1->C1_ITEMCTA := "114"
					
				ENDIF
				
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