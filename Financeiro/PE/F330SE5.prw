#include "Protheus.ch"
  
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  F330SE5 � Autor � Fernando Sigoli       � Data �  02/05/17   ���
�������������������������������������������������������������������������͹��
���Descricao � P.E  manipula Movimentos Banc�rios Processados tendo como   ��
��             par�metro o Recno dos registros SE5 que foram utilizados    ��
��             na Compensa��o                                              ��
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function F330SE5()

Local aRecno := ParamIxb[1]
Local nCntFor :=0 

DbSelectArea("SE5")
DbSetOrder(1)
    
DbSelectArea("SE1")	
DbSetOrder(1)

	For nCntFor := 1 to Len(aRecno)
	SE5->(dbGoto(aRecno[nCntFor])) 
	
		If dbSeek(xFilial("SE1")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA)
			While !Eof() .and. E1_PREFIXO = SE5->E5_PREFIXO .and. E1_NUM = SE5->E5_NUMERO .and. E1_PARCELA = SE5->E5_PARCELA .and. SE5->E5_BANCO <> ''
				If !EMPTY(E1_BAIXA).and. EMPTY(E1_XDTDISP) 
					RecLock("SE1",.F.)
					Replace E1_XDTDISP With SE5->E5_DTDISPO
					MsUnlock()
				EndIF	
	   		DbSkip() 
	   		Enddo
		Endif
	
	Next nCntFor
	
Return
