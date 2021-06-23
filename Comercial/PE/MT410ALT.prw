#include "rwmake.ch"
#include "Protheus.ch"
#include "topconn.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT410ALT � Autor � Fernando Sigoli   � Data �  05/07/17     ���
�������������������������������������������������������������������������͹��
���Descricao � altera��o do pedido. � executado ap�s                      ���
���	a grava��o das altera��es.                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ADORO                                                      ���
����������������������������������������������� �������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MT410ALT()

    Local aArea   := GetArea()
    
    //Everson - 01/03/2018. Chamado 037261.SalesForce.
	If IsInCallStack('U_RESTEXECUTE') .Or. IsInCallStack('RESTEXECUTE')
		RestArea(aArea)
		Return Nil
		
	EndIf
	
    // log de registro de altera��o  
    u_GrLogZBE (Date(),TIME(),cUserName,"ALTERACAO PEDIDO DE VENDA -SC5/SC6","COMERCIAL","MT410ALT",;
    		   "PEDIDO: "+SC5->C5_NUM,ComputerName(),LogUserName())
   	
   	RestArea(aArea)
    
Return