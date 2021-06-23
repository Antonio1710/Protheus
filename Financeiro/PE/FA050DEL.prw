#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

/*
����������������������������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������������������������ͻ��
���Chamado   �FA050DEL  �Autor  � Adoro                                                 � Data �  00/00/0000 ���
������������������������������������������������������������������������������������������������������������͹��
���Ch:043195 � 20/09/2019 - Abel Babini Filho|Incluida condi��o para excluir solicita��o de PA               ���
���          �                                                                                               ���
������������������������������������������������������������������������������������������������������������͹��
���          �                                                                                               ���
���          �                                                                                               ���
������������������������������������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������������������������������
*/

USER FUNCTION FA050DEL()

	LOCAL lRet := .T.
	
	IF ALLTRIM(SE2->E2_TIPO) == 'PA'
	
		IF DDATABASE <> SE2->E2_EMISSAO
		
			IF MSGNOYES("ATEN��O, data da exclus�o diferente de data de emiss�o.Deseja realmente continuar?", "FA050DEL")
			
				lRet := .T. //ESCOLHEU SIM
				
			ELSE	
			
				lRet := .F. //ESCOLHEU NAO
				
			ENDIF
		
		ENDIF
	
		//INICIO Ch:043195 � 20/09/2019 - Abel Babini Filho|Incluida condi��o para excluir solicita��o de PA
		IF lRet
			dbSelectArea("ZFQ")
			dbSetOrder(1)			
			IF ZFQ->(dbSeek(xFilial('ZFQ')+"MAN"+SE2->E2_NUM+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PARCELA))
				If RecLock("ZFQ",.f.)
					ZFQ->(dbDelete())
					ZFQ->(MsUnlock())
				Endif
			ENDIF
		ENDIF
		//FIM Ch:043195 � 20/09/2019 - Abel Babini Filho|Incluida condi��o para excluir solicita��o de PA
	
	ENDIF
	
RETURN(lRet)