#Include "Protheus.ch" 
#include "rwmake.ch"
#include "topconn.ch" 
  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT103MSG  � Autor �Fernando Sigoli     � Data �  18/03/19   ���
�������������������������������������������������������������������������͹��
���Descricao � P.E ocorre ao clicar no bot�o "Fechar", opcao informar     ���
���          � informar os dados para classificar Doc.Entrada             ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��Chamado:047936 Fernando sigoli 13/03/2019. Ao Cancelar, validar se      ���
��               Existe Item de pedido sem preenchimento                  ���				
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT103MSG()
	
	Local aArea   := GetArea()
	Local nCPEDID := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_PEDIDO"		})
	Local nCITEMP := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "D1_ITEMPC"		})
	Local lOk	  := .T.
	Local i   	  := 0  
	
	For i:=1 To Len(aCols)
			 
		If aCols[i] [LEN(aHeader) + 1] == .F. .And. ! IsInCallStack( "U_IntNFEB" )
			
			If !Empty( aCols[i][nCPEDID] ) .and. Empty( aCols[i][nCITEMP] ) 
				ApMsgAlert('Aten��o, item do Pedido nao preenchido'+chr(13)+chr(10)+'As informa�oes Nao ser�o Salvas!!','Documento de Entrada')
				lOk := .F.
			EndIf
		
		EndIf
			
	Next i
	
	RestArea(aArea)

Return lOk