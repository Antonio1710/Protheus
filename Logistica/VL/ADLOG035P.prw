#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE "TOPCONN.CH"

//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������
//�������������������������������������������������������������������������ͻ��
//���Programa  �ADLOG035P �Autor  �WILLIAM COSTA       � Data �  08/03/2018 ���
//�������������������������������������������������������������������������͹��
//���Desc.     �Validacao de campo ZVC_XCREDE para identificar se j� existe ���
//���          �uma credencial para outro caminhoneiro                      ���
//�������������������������������������������������������������������������͹��
//���Uso       � SIGAEST                                                    ���
//�������������������������������������������������������������������������ͼ��
//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������

USER FUNCTION ADLOG035P()

	Local lRet        := .T.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Validacao de campo ZVC_XCREDE para identificar se j� existe uma credencial para outro caminhoneiro')
	
	IF M->ZVC_XCREDE > 0 //SO VERIFICA SE A CREDENCIAL FOR MAIOR QUE ZERO PORQUE TEM VARIAS QUE O CAMPO ESTA ZERO. 
	
		SqlBuscaCredencial(M->ZVC_XCREDE)
	        
		While TRC->(!EOF())
		
			// *** SE ENTRAR AQUI EXISTE UMA CREDENCIAL IGUAL PARA O OUTRO CAMINHONEIRO   ***//
		
			MsgStop("OL� " + Alltrim(cUserName) + ", Existe uma credencial igual para outro caminhoneiro Verifique." + CHR(13) + CHR(10) + ;
			        "Nome Caminhoneiro: " + TRC->ZVC_MOTORI, "ADLOG035P-1 - Valida��o de Campo ZVC_XCREDE")
			        
			lRet := .F.
	           
	        TRC->(dbSkip())
		ENDDO
		TRC->(dbCloseArea())
	
	ENDIF
			
RETURN(lRet)

Static Function SqlBuscaCredencial(cXcrede)

	Local cFilZVC := FwXfilial("ZVC")

	BeginSQL Alias "TRC"
			%NoPARSER%  
			SELECT TOP(1) ZVC_MOTORI,
			               ZVC_CPF,
			               ZVC_XCREDE 
			  FROM %Table:ZVC% WITH(NOLOCK)
			  WHERE ZVC_FILIAL = %EXP:cFilZVC%
			    AND ZVC_XCREDE = %EXP:cXcrede%
			    AND D_E_L_E_T_ <> '*'
    
	EndSQl            
	
RETURN(NIL)
