#include "rwmake.ch"
#include "Protheus.ch"
#include "topconn.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  MT410INC � Autor � fernando sigoli   � Data �  05/07/17      ���
�������������������������������������������������������������������������͹��
���Descricao � inclusao do pedido  � executado ap�s grava��o das inclusao ���
���	                                                                      ���
���          �                                                            ���
������������������������������������� �����������������������������������͹��
���Uso       � ADORO                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MT410INC()

	Local aArea := GetArea()
	
	//Everson - 01/03/2018. Chamado 037261.SalesForce.
	If IsInCallStack('U_RESTEXECUTE') .Or. IsInCallStack('RESTEXECUTE')
		RestArea(aArea)
		Return Nil

	EndIf

	//log da sc5
	u_GrLogZBE (Date(),TIME(),cUserName,"INCLUSAO DO PEDIDO ","COMERCIAL","MT410INC",;
	"PEDIDO: "+SC5->C5_NUM,ComputerName(),LogUserName())  

	RestArea(aArea)

Return