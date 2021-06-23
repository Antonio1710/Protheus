#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADEST032P �Autor  �William Costa       � Data �  22/10/2018 ���
�������������������������������������������������������������������������͹��
���Desc.     �Programa de valida�oes para o Mestre de Inventario onde e   ���
���          �utilizado o campo CBA->CBA_XPRODV onde tem Iniciador de     ���
���          �Browse, Padrao e Gatilho do Campo                           ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAEST MATA030                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER FUNCTION ADEST032P(cParam)
	
	Local cRet := ''

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa de valida�oes para o Mestre de Inventario onde e utilizado o campo CBA->CBA_XPRODV onde tem Iniciador de Browse, Padrao e Gatilho do Campo')
	
	IF cParam == 'BROWSE'
	
		cRet := IIF(EMPTY(CBA->CBA_PROD),Posicione("SBE",1,xFilial("SBE")+CBA->CBA_LOCAL+CBA->CBA_LOCALI,"BE_CODPRO"),CBA->CBA_PROD)
    
    ENDIF
    
    IF cParam == 'PADRAO'
	
		cRet := IIF(EMPTY(CBA->CBA_PROD),Posicione("SBE",1,xFilial("SBE")+CBA->CBA_LOCAL+CBA->CBA_LOCALI,"BE_CODPRO"),CBA->CBA_PROD)
    
    ENDIF
    
    IF cParam == 'GATILHO' 		
		
		cRet := IIF(EMPTY(M->CBA_PROD),Posicione("SBE",1,xFilial("SBE")+M->CBA_LOCAL+M->CBA_LOCALI,"BE_CODPRO"),M->CBA_PROD)
		
	ENDIF
	
RETURN(cRet)