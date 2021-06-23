#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADEST035P �Autor  �WILLIAM COSTA       � Data �  14/11/2018 ���
�������������������������������������������������������������������������͹��
���Desc.     � VALIDACAO DO CAMPO BE_LOCALIZ PARA NAO DEIXAR TER ESPACO   ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER FUNCTION ADEST035P()

	lRet := .T.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'VALIDACAO DO CAMPO BE_LOCALIZ PARA NAO DEIXAR TER ESPACO')
	
	IF INCLUI == .T.
	
		IF AT(' ',ALLTRIM(M->BE_LOCALIZ)) > 0
		
			MsgStop("OL� " + Alltrim(cUserName) + ", Campo de Localiza��o n�o pode ter espa�o em branco.", "ADEST035P")
			lRet := .F.
			
		ENDIF
	ENDIF
	
RETURN(lRet)