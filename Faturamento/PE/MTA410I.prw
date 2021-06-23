#INCLUDE "RWMAKE.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � MTA410I  � Autor � Rogerio Nutti      � Data �  26/01/2004 ���
�������������������������������������������������������������������������͹��
���Descri��o � Ponto de Entrada para gravar campo  C6_ENTREGA             ���
�������������������������������������������������������������������������͹��
���Uso       � Espec�fico Ad'oro                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
       
User Function MTA410I()

	Local nX       := ParamIXB
	Local aArea    := Getarea()
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSC6 := SC6->(GetArea())
	Local nProd    := aScan(aHeader, {|x| ALLTRIM(x[2]) == "C6_PRODUTO" })
	Local nItemPV  := aScan(aHeader, {|x| ALLTRIM(x[2]) == "C6_ITEM" })
	
	IF ACOLS[nX,Len(aHeader)+1] == .F.
	
		DBSELECTAREA("SC6")
		DBSETORDER(1)
		IF DBSEEK(FWXFilial("SC6")+SC5->C5_NUM+ACOLS[nX,nItemPV]+ACOLS[nX,nProd])
		
			RecLock("SC6",.F.)
			
				SC6->C6_ENTREG := SC5->C5_DTENTR
				
			MsUnlock()
		
		ENDIF
	ENDIF
	
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
	RestArea(aArea)

Return(NIL)