#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LP650006  �Autor  �ABEL BABINI FILHO   � Data �  08/10/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     �Lancamento padrao 650006 conta contabil                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACOM                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER FUNCTION LP650006()

	Local aArea		:= GetArea()
	Local lRet 		:= .F.
	Local cAtfBen	:= ''

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	cAtfBen	:= GetAdvFval("SN1","N1_XATFBEN",xFilial("SN1")+SD1->D1_FORNECE+SD1->D1_LOJA+SF1->F1_ESPECIE+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_ITEM,8)

	IF Alltrim(cAtfBen) $ '1,2'
		lRet := .T.
	ENDIF
	
	RestArea(aArea)
Return lRet