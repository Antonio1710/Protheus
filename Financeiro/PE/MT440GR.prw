#include "rwmake.ch"
#include "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT440GR  � Autor � Fernando Sigoli    � Data �  04/07/17   ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de Entrada na libera��o de pedidos manual            ���
���          � Chamado: 036107                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ADORO                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MT440GR()

Local AREAMT440GR := GETAREA()
Local cParam	  := PARAMIXB[1]

	If cParam == 1 //confirmou a libera��o do pedido
	
		//grava log de execucao da rotina
		 u_GrLogZBE (Date(),TIME(),cUserName,"ROTINA DE LIB.PEDIDO MANUAL ","FINANCEIRO","MT440GR",;
 	                 "PEDIDO: "+SC5->C5_NUM,ComputerName(),LogUserName())  
	
	EndIf
	                          
RESTAREA(AREAMT440GR)   

Return .T.