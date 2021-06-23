#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT110APV  � Autor � WILLIAM COSTA      � Data �  25/05/2018 ���
�������������������������������������������������������������������������͹��
���Descricao � Botao aprovacao na Solicitacao de Compra.                  ���
�������������������������������������������������������������������������͹��
���Uso       � Compras.                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
// ############################################################################################################
// ---------+-------------------+--------------------------------------------------------------+---------------
// 07/06/18 | Ricardo Lima      | Ajuste na query para filial 07                               | 
// ---------+-------------------+--------------------------------------------------------------+---------------
// ############################################################################################################
/*/

USER FUNCTION MT110APV()
	
	Local aArea   := GetArea()
	Local cParam1 := ParamIxb[1]
	Local nParam2 := ParamIxb[2]
	Local lRet    := .T.
	Local lAprov  := .F.
	
	IF cParam1 == 'SC1'
	
		SqlLiberacaoUsuario(__cUserId)
		While TRC->(!EOF())
	        
	        lAprov := .T.
            
        	TRC->(dbSkip())
        	
		ENDDO
		TRC->(dbCloseArea())
	ENDIF
	
	IF lAprov == .T.
	
		lRet := .T.
	
	ELSE
	
		MsgAlert("OL� " + Alltrim(cUserName)                 + CHR(10) + CHR(13)+;
		         "N�O � PERMITIDO CLICAR NO BOTAO APROVA��O" + CHR(10) + CHR(13)+;
		         " CASO NECESS�RIO APROVAR / REJEITAR SOLICITA��O DE COMPRA ENTRAR EM CONTATO COM A CONTROLADORIA PARA INCLUIR LIBERA��O", "MT110APV-01")
	
		lRet := .F.
	
	ENDIF
	
	RestArea(aArea)

Return(lRet)

Static Function SqlLiberacaoUsuario(cIdUser)

// Ricardo Lima - 07/06/18
	BeginSQL Alias "TRC"
			%NoPARSER%  
			SELECT PAE_CODUSR,PAE_APRSOL 
			  FROM %table:PAE% PAE
			 WHERE PAE_CODUSR  = %EXP:cIdUser%
			   AND PAE_APRSOL  = 'S'
			   AND PAE.%notDel% 		   
	EndSQl             
RETURN(NIL)
