#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADFIN056P �Autor  �William Costa       � Data �  24/05/2018 ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao de campo A1_CODMUNE pois estava dando erro        ���
���          �para usuarios do financeiro                                 ���
�������������������������������������������������������������������������͹��
���Uso       � INTEGRACAO SURICATO -SCHEDULE                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER FUNCTION ADFIN056P()

	Local lRet := .F.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Validacao de campo A1_CODMUNE pois estava dando erro para usuarios do financeiro')
	
	lRet := IIF(FUNNAME() == "U_ADOA005",VerificaCC2PB3(),ExistCpo("CC2",M->A1_ESTE+M->A1_CODMUNE))              
	
RETURN(lRet)

Static Function VerificaCC2PB3()

	Local lRet := .F.
	
	SqlCC2(M->PB3_UFENT,M->PB3_CODMUE)
    
    While TRC->(!EOF())
                  
        lRet := .T.
        
    	TRC->(dbSkip())
	ENDDO
	TRC->(dbCloseArea())
	
RETURN(lRet)

Static Function SqlCC2(cEst,cMun)

	BeginSQL Alias "TRC"
		%NoPARSER%  
		SELECT CC2_EST,CC2_CODMUN,CC2_MUN 
		  FROM CC2010
		 WHERE CC2_EST    = %EXP:cEst%
		   AND CC2_CODMUN = %EXP:cMun%
	EndSQl 
	            
RETURN(NIL)