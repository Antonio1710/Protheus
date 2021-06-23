#include "rwmake.ch"
#include "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT440VLD  � Autor � Fernando Sigoli    � Data �  05/07/17   ���
�������������������������������������������������������������������������͹��
���Descricao � POnto de Entrada na libera��o de pedidos automatico        ���
���          � Chamado: 036107                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ADORO                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
USER FUNCTION MT440VLD()

Local AREA440vld := GETAREA()

	//grava log de execucao da rotina
	u_GrLogZBE (Date(),TIME(),cUserName,"ROTINA DE LIB.PEDIDO AUTOMAT","FINANCEIRO","MT440VLD",;
				"PEDIDO DE: "+MV_PAR02+" ATE: "+MV_PAR03+" CLIENTE DE: "+MV_PAR04+" ATE: "+MV_PAR05+;
	 			"ENTREGA DE:"+DTOC(MV_PAR06)+" ATE: "+DTOC(MV_PAR07),ComputerName(),LogUserName())
	
                          
RESTAREA(AREA440VLD)     
	
Return .T.