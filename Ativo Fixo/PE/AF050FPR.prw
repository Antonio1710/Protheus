
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO3     �Autor  �KF			         � Data �  06/07/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � N�o gera deprecia��o de itens baixados                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � P11 - Adoro SA                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AF050FPR

Local lRet 	 	:= .F.         
Local aAreaSN3  := SN3->(GetArea())
Local cChave	:= PARAMIXB[1]

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'N�o gera deprecia��o de itens baixados')

If FunName()=='ATFA050'
	DbSelectArea("SN3")
	SN3->(DbGoto((cAliasSn3)->RECNO))
	If !Empty(SN3->N3_DTBAIXA)
		lRet 	 	:= .T. 
		SN3->(Reclock("SN3",.F.))
		SN3-> N3_FIMDEPR := SN3->(N3_DTBAIXA)		
		SN3->(Msunlock())
	EndIf
ElseIf FunName()=='ATFA070'
	If !Empty(SN3->N3_DTBAIXA)
		lRet 	 	:= .T. 
		SN3->(Reclock("SN3",.F.))
		SN3-> N3_FIMDEPR := SN3->(N3_DTBAIXA)		
		SN3->(Msunlock())
	EndIf
EndIf

RestArea(aAreaSN3)
Return lret