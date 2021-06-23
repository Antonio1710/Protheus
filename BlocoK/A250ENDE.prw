#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |A250ENDE  �Autor  �Fabricio Fran�a     � Data �  02/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de Entrada que seguere o endere�o a ser utilizado no  ���
���          �consumo das Ops.                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Prothues 11 - Adoro                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function A250ENDE()

Local aAreaAnt:= GetArea()	
Local cEnd 	:= GetMv('MV_X_ENPRO',.F.,"PRODUCAO")   	// endere�o padrao para producao

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Ponto de Entrada que seguere o endere�o a ser utilizado no consumo das Ops.')

If Localiza(SD4->D4_COD)                                       
	RestArea(aAreaAnt)
	Return (cEnd)
EndIf

RestArea(aAreaAnt)
Return(nil)