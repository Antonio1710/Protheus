#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADFIS024P �Autor  �William Costa       � Data �  17/04/2018 ���
�������������������������������������������������������������������������͹��
���Desc.     �PROGRAMA UTILIZADO NO SX1 DA PERGUNTA CANHOTO               ���
���          �VALIDACAO DO CAMPO MV_PAR08                                 ���
�������������������������������������������������������������������������͹��
���Uso       � FISCAL                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER FUNCTION ADFIS024P()

	Local lRet := .F.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'PROGRAMA UTILIZADO NO SX1 DA PERGUNTA CANHOTO VALIDACAO DO CAMPO MV_PAR08')
	
	IF LEN(ALLTRIM(MV_PAR08)) == 9 .AND. MV_PAR08 >= MV_PAR07
	
		lRet := .T.
	
	ENDIF  
	
	IF MV_PAR08 == 'ZZZZZZZZZ'
	 
	 	lRet := .T.
	 
	ENDIF
	
RETURN(lRet)