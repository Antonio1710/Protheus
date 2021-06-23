#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADVEN031P �Autor  �WILLIAM COSTA       � Data �  25/10/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao de usuario para verificar o campo M->PB3_CEP      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ADVEN031P()

	Local lRet := .T.  
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Validacao de usuario para verificar o campo M->PB3_CEP')
	
	IF (LEN(REPLACE(Alltrim(M->PB3_CEP),'-','')) == 8     .OR.  ;
	   M->PB3_EST                                == "EX") .AND. ;
	   AT('--',Alltrim(M->PB3_CEP))              == 0
	
		lRet := .T.
		
	ELSE
	
		IF AT('--',Alltrim(M->PB3_CEP)) > 0
		
 			MSGALERT("Aten��o existe dois tra�os no CEP, favor verificar!!!")
			lRet := .F. 
		
		ENDIF		
		            
		IF LEN(REPLACE(Alltrim(M->PB3_CEP),'-','')) < 8 
		    
			IF lRet == .T.
			
				MSGALERT("Aten��o existe tra�os a mais no CEP, favor verificar!!!")
				lRet := .F. 
				
			ENDIF
		
		ENDIF		
	ENDIF
Return(lRet)