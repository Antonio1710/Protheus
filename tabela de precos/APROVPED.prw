#INCLUDE "PROTHEUS.CH" 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �APROVAPED � Autor � Mauricio da Silva     � Data � 03/05/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � rotina para escolha de qual tipo de pedido a ser liberado. ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���              �        |      |                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                  

User Function APROVPED()

Local aArea := GetArea()
Local nOp

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'rotina para escolha de qual tipo de pedido a ser liberado.')

nOp := Aviso("Atencao","Escolha o tipo de aprova��o ?",{" REDE "," VAREJO "})
If nOp == 1
	U_LIBPED2()
Else
	U_LIBPED1()
EndIf	

RestArea(aArea)

Return(.T.)