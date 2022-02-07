#Include "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CEXEXXML � Autor � Fernando Sigoli       � Data �27/03/2019���
�������������������������������������������������������������������������Ĵ��
���Descri��o � P.E. na exclusao de XML (Central XML).Valida se usuario    ���
���          � pode ou nao excluir                          		      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Adoro                                                      ���
�������������������������������������������������������������������������Ĵ��
���Chamado: TI  - Na exclusao do XML, verifica e remove a nota da tabela  ���
���ZCW registros de notas recusadas										  ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������    
*/

User Function CEXEXXML()  
	
	Local aParXML	:= PARAMIXB
	Local lRetorno	:= .T.
    Local _aArea	:= getArea()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'CENTRALXML- P.E na na exclusao de XML (Central XML).Valida se usuario ')
	
	// NF-e
	If aParXML[ 01 ] == "RECNFXML" 
		
		If Alltrim(RECNFXML->XML_KEYF1) == ""
		
			dbSelectArea('ZCW')
			dbSetOrder(2)
			If ZCW->(dbSeek(xFilial('ZCW')+RECNFXML->XML_CHAVE))
				RecLock("ZCW",.F.)
				ZCW->(dbDelete())
				ZCW->(MsUnlock())
				
				//grava log
				u_GrLogZBE (Date(),;
				TIME(),;
				cUserName,;
				"EXCLUSAO RECUSA DE XML","FISCAL","CEXEXXML",;
				"NF: "+substr(RECNFXML->XML_NUMNF,4,9)+" Serie: " +substr(RECNFXML->XML_NUMNF,1,3)+ " User: " +__cUserId,;
				ComputerName(),;
				LogUserName())		
			
			Endif			
				
		Else
		
			Alert("Nota Fiscal ja classificada. Impossivel excluir XML!")
			lRetorno := .F.
		
		Endif
	
	ENDIF
	
	ZCW->(dbCloseArea())
	RestArea(_aArea)    

Return lRetorno