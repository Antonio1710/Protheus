#Include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LP531     �Autor  �Ana Helena          � Data �  16/10/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � LP 531-209 - Cancelamento de baixa.                        ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function LP531209()  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')


// Defini��o das vari�veis.
Public _aArea   	:= GetArea()
Public _aAreaSE5	:= {}
Public _nRet		:= 0
                   
dbSelectArea("SE5")
_aAreaSE5 := GetArea()
If SE5->E5_RECPAG=="P" .AND. ALLTRIM(SE5->E5_TIPODOC)=="BA" .AND. ALLTRIM(SE5->E5_MOTBX)=="NOR" .AND.;
	!EMPTY(SE5->E5_FORNECE) .AND. FUNNAME()<>'FINA290' .AND. ALLTRIM(SE5->E5_TIPO) <> "RJ"
	_nRet := SE5->(E5_VALOR+E5_VLDESCO-E5_VLJUROS-E5_VLMULTA)
Else
	_nRet := 0
Endif	

RestArea(_aAreaSE5)
RestArea(_aArea)

Return(_nRet)
