#Include "PROTHEUS.CH" 
#Include "RWMAKE.CH"
                       
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F060DPM   �Autor  �Fernando Sigoli  � Data �  18/08/17      ���
�������������������������������������������������������������������������͹��
���Desc.     �Pornto de entrada utilizado para nao deixar vincular titulo ���
���          �em bodero que esteja sem numero bancario                    ���
�������������������������������������������������������������������������͹��
���Uso       � ADORO                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function F060DPM()

	Local bCheck 	:= .F.
	
	If allTrim(E1_OK) <> ""
		bCheck := .T.
	EndIf
	
	If bCheck .and. Empty(E1_NUMBCO) 
		Alert("ATEN��O "+cUsername+": T�tulo "+E1_NUM+" esta sem informa��o de n�mero banc�rio, o mesmo nao ser� associado ao border�.")
		E1_OK := ""
	EndIf
	
Return(1)   


