#include 'rwmake.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � MT410BRW � Autor � WELLINGTON SANTOS  � Data �  01/16/07   ���
�������������������������������������������������������������������������͹��
��� Desc.    � PE para filtrar o Browser de pedido pelo vendedor ou super-���
���          � visor                                                      ���
�������������������������������������������������������������������������͹��
��� Uso      � ADORO                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT410BRW
Local _cCodUsua := __cUserID

&&Mauricio - 01/10/15 - este ponto de entrada n�o estava em uso e n�o estava adicionado ao projeto do cliente, apenas existindo no diretorio faturamento do projeto.
&&Assim desabilitei o que havia nele e s� ficou o meu tratamento novo a ser implementado para mostrar pedidos de venda deletados ao usuario do Sr. Caio(solicitado por Evandro).

&&Codigo do usuario Caio no sistema = 000559   //Vagner_C 000835    //MDS  001402

IF _cCodUsua == "000559"  
   dbselectarea("SC5")
   SET DELETED OFF
Endif
	
Return()