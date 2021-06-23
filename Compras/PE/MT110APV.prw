#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT110APV  º Autor ³ WILLIAM COSTA      º Data ³  25/05/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Botao aprovacao na Solicitacao de Compra.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Compras.                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
	
		MsgAlert("OLÁ " + Alltrim(cUserName)                 + CHR(10) + CHR(13)+;
		         "NÃO É PERMITIDO CLICAR NO BOTAO APROVAÇÃO" + CHR(10) + CHR(13)+;
		         " CASO NECESSÁRIO APROVAR / REJEITAR SOLICITAÇÃO DE COMPRA ENTRAR EM CONTATO COM A CONTROLADORIA PARA INCLUIR LIBERAÇÃO", "MT110APV-01")
	
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
