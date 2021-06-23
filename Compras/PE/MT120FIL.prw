#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT120OK   �Autor  �DANIEL              � Data �  03/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada executado para fazer o filtro no pedido   ���
���          � compras  para garantir a gravacao da filial de entrega     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT120FIL     

//+----------------------------------------------------------+
//|Declaracao de Variaveis                                   |
//+----------------------------------------------------------+

Private _aArea		:=GetArea()				//Salva a Area Atual  
Private _cFil		:=CFILANT 				//Codigo da Filial Atual (ALTERADO POR ADRIANA EM 28/01/08)	//SM0->M0_CODFIL   	

//+-----------------------+
//|Ambiente               |
//+-----------------------+
DbSelectArea("SC7") 
DbSetOrder(13)        
DbGoTop()
//+-----------------------+
//+ Varrendo SC7          |
//+-----------------------+
	//+----------------------------------+
	//|Verificando se a Filial de entrega| 
	//|esta vazia                        |
	//+----------------------------------+
While !eof() .and. Empty(SC7->C7_FILENT)
		//+--------------------------+
		//|Atualizando a Filial      |
		//+--------------------------+
		RecLock("SC7",.F.)							//Append
			REPLACE SC7->C7_FILENT WITH _cFil	//Replace no Registro
		MsUnlock()
	DbSkip()
End


RestArea(_aArea)									//Retorna a Area Atual

Return ("")                               //nao vou retornar nada, nao quero filtrar